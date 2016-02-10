import ObjectiveC.NSObject
import Alamofire
import SwiftyJSON
import CoreData

let account = Account()
let baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String


class Account: NSObject {
    
    // Me
    var user: User!
    
    // API Token
    dynamic var token: String!
    
    // Visible users
    var users = [User]()
    
    // Stored chats
    var chats = [Chat]()
    
    // Requests
    var requests = [Request]()
    
    var relationships: JSON?

    func logOut() {
        token = nil
        user = nil
        chats = [Chat]()
        users = [User]()
    }
    
    /**
     * Con questo metodo, pushamo le informazioni relative alle immagini
     * dell'utente 'me' in remoto
     * Effettuiamo una richiesta HTTP per ogni immagine per non avere body
     * troppo grossi che possono generare dei 413 lato server.
     */
    func pushImages() {
        
        for( var i = 0; i < MAX_PHOTOS ; i++ ) {
            // Di base, abbiamo un'immagine vuota
            var imageData = ""
            // Controlliamo se siamo sempre dentro l'array
            if(self.user.images.count > i) {
                // Check se l'immagine esiste (non si sa mai!)
                if let img = self.user.images[i] {
                    let resizedImg = ImageUtil.resize(ImageUtil.cropToSquare(image: img), targetSize: CGSize(width: 500, height: 500))
                    let imgProfile: NSData = UIImagePNGRepresentation(resizedImg)!
                    imageData = imgProfile.base64EncodedStringWithOptions([])
                }
            }
            Alamofire.request(.POST, baseUrl + "/api/users/me/images", parameters: [
                "image" : i,
                "imageData" : imageData
            ],headers: ["X-Api-Token": account.token!,"Content-Type": "application/x-www-form-urlencoded"])
        }
    }
    
    func refreshChats(completion: (result: Bool) -> Void) {
        if let _ = account.token {
            for(var i = 0; i < account.chats.count; i++){
                account.chats[i].fetchNewMessages({ (result) -> Void in
                    if(i == account.chats.count) {
                        completion(result: true)
                    }
                })
            }
        }
    }
    
    /**
     * Questo metodo aggiorna le relazioni interrogando il server
     * Viene poi utilizzata la funzione updateRelationships() per 
     * parsare i dati ritornati
     */
    func refreshRelationships(completion: (result: Bool) -> Void) {
        let manager = Alamofire.Manager.sharedInstance
        if let token = account.token {
            manager.request(.GET, baseUrl + "/api/users/me/relationships" , encoding : .JSON, headers: ["X-Api-Token": token])
                .responseJSON { _,_,result in
                    switch result {
                    case .Success(let data):
                        self.relationships = JSON(data)
                        self.updateRelationships()
                        completion(result: true)
                    case .Failure(_, let error):
                        print("Request failed with error: \(error)")
                    }
            }
        }
    }
    
    /**
     * Prendiamo i dati che ci siamo salvati al momento dell'accesso o in altro
     * modo e ora che abbiamo ricaricato le chat, li utilizziamo per aggiornare 
     * le relazioni dei vari utenti
     * Questo metodo si occupa anche di creare le richieste ricevute
     */
    func updateRelationships() {
        // Resettiamo l'array
        requests = [Request]()
        
        for (key, value) in self.relationships! {
            
            if let user = Chat.getChatByUserId(key).0?.user {
                if(value == "requested") {
                    user.hasSentRequest = true
                    user.hasReceivedRequest = false
                } else if(value == "received") {
                    user.hasReceivedRequest = true
                    user.hasSentRequest = false
                    
                    // Abbiamo l'utente, non stiamo a riprenderlo
                    requests.append(Request(user_id: key, user: user))
                    
                } else if(value == "accepted") {
                    // Nuova amicizia! -> Aggiorniamo l'utente
                    // NOTA: Quando si fa l'accept, viene già settato da quel metodo,
                    // questo è il caso in cui è l'altro utente che ha accettato
                    if(user.isFriend == false) {
                        user.fetch({ (result) -> Void in
                        })
                    }
                    // Non serve aggiornare i campi, lo fa già la fetch
                    else {
                        user.isFriend = true
                        user.hasReceivedRequest = false
                        user.hasSentRequest = false
                    }
                    
                }
            } else {
                if(value == "received") {
                    // Se abbiamo già l'utente lo prendiamo da li
                    if let user = User.getUserById(key).0 {
                        requests.append(Request(user_id: key, user: user))
                    }
                    // Non abbiamo l'utente ne fra quelli delle chat ne 
                    // fra quelli intorno, dobbiamo recuperarlo
                    else {
                        requests.append(Request(user_id: key))
                    }
                }
            }
        }
    }

    /** 
     * Chiamata al server in cui vengono inviati i dati sulla posizioni attuale e
     * indietro otteniamo i dati degli utenti intorno che plottiamo sulla mappa
     */
    func fetchNearbyUsers(){
        if let userPosition = self.user.position{
            Alamofire.request(.POST, baseUrl + "/api/users", parameters: ["lat" : userPosition.latitude, "lon": userPosition.longitude], encoding : .JSON, headers: ["X-Api-Token": account.token!])
                .responseJSON { _,_,result in
                    switch result {
                    	case .Success(let data):
                            // Removing all current nearby users
                            self.users.removeAll(keepCapacity: false)
                        	var json = JSON(data)
                            for(var i = 0; i < json.count; i++){
                                if(json[i]["user"].count > 0) {
                                    let userData = json[i]["user"]
                                    let position = json[i]["position"]
                                    let newUser = User(userId: userData["_id"].string!, firstName: userData["name"].string!, lastName: userData["surname"].string!)
                                    // Retreive user details
                                    newUser.fetch({ (result) -> Void in
                                        let userPosition = CLLocationCoordinate2D(latitude: position["latitude"].double!, longitude: position["longitude"].double!)
                                        newUser.position = userPosition
                                        
                                        // Avoid possible race condition by deleting user if somehow is already
                                        // in our list
                                        if let existingUserIndex = User.getUserById(newUser.userId).1 {
                                            self.users.removeAtIndex(existingUserIndex)
                                        }
                                        // Appending new user
                                        self.users.append(newUser)
                                    })
                                }
                            }
                        
                        case .Failure(_, let error):
                            print("Request failed with error: \(error)")
                    }
                }
        	}
    }
    
    /*
     * Chiamata API per recuperare le informazioni di uno specifico utente
     * dal sever
     */
    func fetchUserByID(userId: String, completion: (result: User? ) -> Void){
        Alamofire.request(.GET, baseUrl + "/api/users/" + userId, encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON { _,_,result in
                switch result {
                    case .Success(let data):
                        var json = JSON(data)
                        print(json)
                        let newUser = User(userId: json["_id"].string!, firstName: json["name"].string!, lastName: json["surname"].string!)
                        newUser.decodeImages(json["images"])
                        completion(result: newUser)
                    case .Failure(_, let error):
                        print("Request failed with error: \(error)")
                }
        }

    }
    
    func setLocation(location: CLLocationCoordinate2D){
        //Passando oggetto CLLocation, setta account.user.location e poi fa chiamata di ping al server
        if user != nil{
            account.user.position = location
            self.fetchNearbyUsers()
        }        
        
    }
    
    func checkNewChat( completion: (Void) -> Void){
        Alamofire.request(.GET, baseUrl + "/api/chat", encoding : .JSON, headers: ["X-Api-Token": account.token])
            .responseJSON { _,_,result in
                
                switch result {
                case .Success(let data):
                    var json = JSON(data)
                    let length = json.count
                    
                    if(length == 0){
                        completion()
                    }
                    
                    var atLeastOneNew = false
                    
                    for(var i = 0; i < length; i++ ){
                        
                        let innerData = json[i]
                        let user1 = innerData["_id"]["user1"].string
                        let user2 = innerData["_id"]["user2"].string
                        
                        var newUser: User
                        let user1MessagesCount = innerData["user1"].count
                        let user2MessagesCount = innerData["user2"].count
                        
                        //This date is only needed to initialize the chat. It will be updated after
                        let date = NSDate()
                        if(Chat.getChatByUserId(user1!).0 == nil && Chat.getChatByUserId(user2!).0 == nil ){
                            
                            atLeastOneNew = true
                            
                            if (user1 == account.user.userId){
                                //Creiamo un nuovo oggetto user che ha come utente l'id di user2, poichè entrati in questo if user1 coincide con l'id utente dell'accunt in uso. Altrimenti inizializziamo l'user con id user1
                                newUser = User(userId: user2!,firstName: "",lastName: "")
                            }else{
                                newUser = User(userId: user1!,firstName: "",lastName: "")
                            }
                            // Retrieve user data
                            newUser.fetch({ (result) -> Void in
                                
                                let newChat = Chat(user: newUser,lastMessageText: "",lastMessageSentDate: date)
                                
                                for(var k = 0 ; k < user1MessagesCount; k++){
                                    newChat.allMessages.append(ServerAPIController.createJSQMessage(user1!, localMessage: innerData["user1"][k]))
                                    if(user1 != account.user.userId){
                                    	newChat.unreadMessageCount++
                                    }
                                }
                                for (var k = 0; k < user2MessagesCount; k++){
                                    newChat.allMessages.append(ServerAPIController.createJSQMessage(user2!, localMessage: innerData["user2"][k]))
                                    if(user2 != account.user.userId){
                                    	newChat.unreadMessageCount++
                                    }
                                }
                                newChat.reorderChat()
                                newChat.saveNewChat()
                                newChat.insertChat()
                                completion()
                            })
                        }
                        
                    }
                    
                    if(atLeastOneNew == false){
                        completion()
                    }
                case .Failure(_, let error):
                    print("Request failed with error: \(error)")
                }
                
        }
	
    }
}
