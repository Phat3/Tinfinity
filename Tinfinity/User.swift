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
    
    init(userId: String, firstName: String, lastName: String) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
    }
    
    /**
     * Recuperiamo uno specifico utente a partire dal suo userId
     * @returns User
     */
    static func getUserById(user_id: String) -> User? {
        for(var i=0; i < account.users.count; i++){
            if (account.users[i].userId == user_id){
                return account.users[i]
            }
        }
        return nil
    }
    
    func sendFriendRequest(completion: (result: Bool) -> Void) {
        
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, baseUrl + "/api/users/" + userId + "/add" , encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON { _,_,result in
                
                switch result {
                case .Success(_):
                    self.hasSentRequest = true
                    completion(result: true)
                case .Failure(_, let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    /**
     * Method used to accept the friend request
     */
    func acceptFriendRequest(completion: (result: Bool) -> Void) {
        
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, baseUrl + "/api/users/" + userId + "/accept" , encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON { _,_,result in
                
                switch result {
                case .Success(_):
                    self.hasSentRequest = false
                    self.hasReceivedRequest = false
                    self.isFriend = true
                    completion(result: true)
                case .Failure(_, let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    /**
     * Method used to decline the user friend request
     */
    func declineFriendRequest(completion: (result: Bool) -> Void) {
        
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, baseUrl + "/api/users/" + userId + "/decline" , encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON { _,_,result in
                
                switch result {
                case .Success(_):
                    self.hasSentRequest = false
                    self.hasReceivedRequest = false
                    self.isFriend = false
                    completion(result: true)
                case .Failure(_, let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    /**
     * Recuperiamo dal server le informazioni legate all'utente
     */
    func fetch(completion: (result: User? ) -> Void) {
        if(account.token != nil) { // Check
       Alamofire.request(.GET, NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String + "/api/users/" + self.userId, encoding : .JSON, headers: ["X-Api-Token": account.token!])
            .responseJSON { _,_,result in
                
                switch result {
                    case .Success(let data):
                        let json = JSON(data)
                        if let _ = json["error"].string{
                            
                            for(var i=0; i < account.chats.count; i++){
                                if (account.chats[i].user.userId == self.userId){
                                    account.chats.removeAtIndex(i)
                                    print("An user has been removed from the array")
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
                            
                            if(json["relationship"] == "requested") {
                                self.hasSentRequest = true
                            } else if(json["relationship"] == "received") {
                                self.hasReceivedRequest = true
                            } else if(json["relationship"] == "accepted") {
                                self.isFriend = true
                            }
                        
                            // Lets download the image
                            self.decodeImages(json["images"])
                            
                            completion(result: self)
                        }
                	case .Failure(_, let error):
                    	print("Request failed with error: \(error)")
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

