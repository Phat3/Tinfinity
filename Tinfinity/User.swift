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
    var imageUrl : String?
    var token: String?
    var name: String? {
        return firstName + " " + lastName
    }
    var initials: String? {
        var initials: String?
        for name in [firstName, lastName] {
            var initial = name.substringToIndex(advance(name.startIndex, 1))
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
     * Recuperiamo dal server le informazioni legate all'utente
     */
    func fetch() {
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String + "/api/users/" + userId, encoding : .JSON)
            .responseJSON { (request, response, data, error) in
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error!.localizedDescription)
                } else {
                    var json = JSON(data!)
                    self.firstName = json["name"].string!
                    self.lastName = json["surname"].string!
                    self.imageUrl = json["image"].string!
                    if(json["gender"] == "male") {
                        self.gender = Gender.Male
                    } else {
                        self.gender = Gender.Female
                    }
                }}
    }
    

}

