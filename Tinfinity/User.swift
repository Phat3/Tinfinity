//
//  UserProfile.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//
import Foundation.NSString
import UIKit
import Alamofire
import SwiftyJSON

// Maximum number of photos a user can have
let MAX_PHOTOS = 6

class User {
    
    enum Gender {
        case Male
        case Female
    }
    
    var userId: String
    var firstName: String
    var lastName: String
    var gender: Gender?
    var email: String?
    var age: String?
    
    // We keep here the info wether we're friends or not
    var isFriend: Bool = false;
    
    // The actual user sent a friend request
    var hasSentRequest: Bool = false
    
    // This user has sent to the actual user a request
    var hasReceivedRequest: Bool = false
    
    // Main image
    var image: UIImage? {
        return images[0]
    }
    
    // Images array
    var images = [UIImage?](count: MAX_PHOTOS, repeatedValue:nil)
    
    // User position
    var position: CLLocationCoordinate2D?
    
    
    /* Utilities */
    
    // Fullname
    var name: String? {
        return firstName + " " + lastName
    }
    
    // User initials
    var initials: String? {
        var initials: String?
        for name in [firstName, lastName] {
            let initial = name.substringToIndex(name.startIndex.advancedBy(1))
            if initial.lengthOfBytesUsingEncoding(NSNEXTSTEPStringEncoding) > 0 {
                initials = (initials == nil ? initial : initials! + initial)
            }
        }
        return initials
    }
    
    /**
     * Utilizziamo questo costruttore quando abbiamo solo l'id 
     * dell'utente e nessuna altra informazione e lasciamo che sia
     * il modello a recuperare le informazioni su se stesso
     */
    init(userId: String) {
        self.userId = userId
        self.firstName = ""
        self.lastName = ""
        self.fetch { (result) -> Void in
            
        }
    }
    
    
    init(userId: String, firstName: String, lastName: String) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
    }
    
    /**
     * Recuperiamo uno specifico utente a partire dal suo userId
     * @returns User|nil
     */
    static func getUserById(user_id: String) -> (User?, Int?) {
        for(var i=0; i < account.users.count; i++){
            if (account.users[i].userId == user_id){
                return (account.users[i],i)
            }
        }
        return (nil,nil)
    }
    
    /**
     * Distance from the current user. If the user is not nearby, returns nil
     * @returns CLLocationDistance|nil
     */
    var distance: CLLocationDistance? {
        if let position = self.position {
            let start = CLLocation(latitude: position.latitude, longitude: position.longitude)
            let end = CLLocation(latitude: account.user.position!.latitude, longitude: account.user.position!.longitude)
            let distance = start.distanceFromLocation(end)
            return distance
        }
        return nil
    }
    
    func sendFriendRequest(completion: (result: Bool) -> Void) {
        
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, baseUrl + "/api/users/" + userId + "/add" , encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON {result in
                switch result.result {
                case .Success(_):
                    self.hasSentRequest = true
                    completion(result: true)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    ServerAPIController.networkError()
                    completion(result: false)
                }
        }
    }
    
    /**
     * Method used to accept the friend request
     */
    func acceptFriendRequest(completion: (result: Bool) -> Void) {
        
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, baseUrl + "/api/users/" + userId + "/accept" , encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON {result in
                switch result.result {
                case .Success(_):
                    self.hasSentRequest = false
                    self.hasReceivedRequest = false
                    self.isFriend = true
                    
                    // Eliminiamo la richiesta dall'array
                    let (_, i) = Request.getRequestByUserId(self.userId)
                    if let index = i {
                        account.requests.removeAtIndex(index)
                    }
                    
                    // Aggiorniamo le informazioni sull'utente
                    self.fetch({ (result) -> Void in
                        completion(result: true)
                    })
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    ServerAPIController.networkError()
                    completion(result: false)
                }
        }
    }
    
    /**
     * Method used to decline the user friend request
     */
    func declineFriendRequest(completion: (result: Bool) -> Void) {
        
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, baseUrl + "/api/users/" + userId + "/decline" , encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON {result in
                switch result.result {
                case .Success(_):
                    self.hasSentRequest = false
                    self.hasReceivedRequest = false
                    self.isFriend = false
                    
                    // Eliminiamo la richiesta dall'array
                    let (_, i) = Request.getRequestByUserId(self.userId)
                    if let index = i {
                        account.requests.removeAtIndex(index)
                    }
                    completion(result: true)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    ServerAPIController.networkError()
                    completion(result: false)
                }
        }
    }
    
    /**
     * Recuperiamo dal server le informazioni legate all'utente
     */
    func fetch(completion: (result: User? ) -> Void) {
       if let token = account.token { // Check
       Alamofire.request(.GET, NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String + "/api/users/" + self.userId, encoding : .JSON, headers: ["X-Api-Token": token])
            .responseJSON {result in
                switch result.result {
                    case .Success(let data):
                        let json = JSON(data)
                        if let _ = json["error"].string{
                            for(var i=0; i < account.chats.count; i++){
                                if (account.chats[i].user.userId == self.userId){
                                    account.chats.removeAtIndex(i)
                                    completion(result: nil)
                                }
                            }
                        }else{
                            self.firstName = json["name"].string!
                            self.lastName = json["surname"].string!
                            
                            if(json["gender"] == "male") {
                                self.gender = Gender.Male
                            } else {
                                self.gender = Gender.Female
                            }
                            
                            self.age = String(json["age"]) != "null" ? String(json["age"]) : nil
                            
                            // Il motivo per cui aggiorniamo sempre tutti 
                            // e tre le variabili, è perchè potrebbe essere 
                            // un aggiornamento di un utente esistente con 
                            // conseguente possibile variazione di relazione
                            if(json["relationship"] == "requested") {
                                self.hasSentRequest = true
                                self.hasReceivedRequest = false
                                self.isFriend = false
                            } else if(json["relationship"] == "received") {
                                self.hasReceivedRequest = true
                                self.hasSentRequest = false
                                self.isFriend = false
                            } else if(json["relationship"] == "accepted") {
                                self.isFriend = true
                                self.hasReceivedRequest = false
                                self.hasSentRequest = false
                            }
                        
                            // Lets download the image
                            self.decodeImages(json["images"])
                            
                            completion(result: self)
                        }
                	case .Failure(let error):
                    	print("Request failed with error: \(error)")
                        ServerAPIController.networkError()
                        completion(result: nil)
                }
            }
        }
    }

    
    /**
     * Decodes the base64 images data into a UIImage with
     * a default image fallback
     */
    func decodeImages(images: JSON) {
        for(var i = 0; i < images.count; i++) {
            if let base64String = images[String(i)].string {
                let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0) )
                self.images[i] = UIImage(data: decodedData!)
            }
        }
        
        // Fallback for main image
        if(self.image == nil) {
            self.images[0] = UIImage(named: "Blank")
        }
    }
    
}

