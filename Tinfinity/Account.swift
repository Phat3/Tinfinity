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
        
        for( var i = 0; i < self.user.images.count ; i++ ) {
            if let img = self.user.images[i] {
                let resizedImg = ImageUtil.resize(ImageUtil.cropToSquare(image: img), targetSize: CGSize(width: 200, height: 200))
                let imgProfile: NSData = UIImagePNGRepresentation(resizedImg)!
                Alamofire.request(.POST, baseUrl + "/api/users/me/images", parameters: [
                    "image" : i,
                    "imageData" : imgProfile.base64EncodedStringWithOptions([])
                ],headers: ["X-Api-Token": account.token!,"Content-Type": "application/x-www-form-urlencoded"])
            }
        }
    }
    
    /**
     * Prendiamo i dati che ci siamo salvati al momento dell'accesso e ora che 
     * abbiamo ricaricato le chat, li utilizziamo per aggiornare le relazioni 
     * dei vari utenti
     */
    func updateRelationships() {
        for (key, value) in self.relationships! {
            if let user = Chat.getChatByUserId(key).0?.user {
                if(value == "requested") {
                    user.hasSentRequest = true
                    user.hasReceivedRequest = false
                } else if(value == "received") {
                    user.hasReceivedRequest = true
                    user.hasSentRequest = false
                } else if(value == "accepted") {
                    user.isFriend = true
                    user.hasReceivedRequest = false
                    user.hasSentRequest = false
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
                        	var json = JSON(data)
                            for(var i = 0; i < json.count; i++){
                                
                                if(json[i]["user"].count > 0) {
                                    let userData = json[i]["user"]
                                    let position = json[i]["position"]
                                    let newUser = User(userId: userData["_id"].string!, firstName: userData["name"].string!, lastName: userData["surname"].string!)
                                    newUser.fetch({ (result) -> Void in
                                        let userPosition = CLLocationCoordinate2D(latitude: position["latitude"].double!, longitude: position["longitude"].double!)
                                        
                                        newUser.position = userPosition
                                        self.users.removeAll(keepCapacity: false)
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
}
