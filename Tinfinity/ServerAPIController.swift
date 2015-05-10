//
//  ServerAPIController.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//

import Foundation
import Alamofire
import SwiftyJSON

class ServerAPIController{
    
    var FBToken : String
    let authenticationPath: String
    let baseUrl: String
    
    init(FBAccessToken: String){
        FBToken = FBAccessToken
        baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String
        authenticationPath = NSBundle.mainBundle().objectForInfoDictionaryKey("Authentication Path") as! String
    }
    
    //Funzione che chiama il server e ritorna un'istanza di UserProfile
    func retrieveProfileFromServer(completion: (result: UserProfile) -> Void){
        
        var profileInfo : UserProfile?
        
        Alamofire.request(.POST, baseUrl + authenticationPath, parameters: ["token" : FBToken], encoding : .JSON)
            .responseJSON { (request, response, data, error) in
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error!.localizedDescription)
                }
                
                var json = JSON(data!)
                
                let name = json["name"].string;
                let surname = json["surname"].string;
                profileInfo = UserProfile(name: name!, surname: surname!)
                profileInfo!.email = json["email"].string;
                
                let url = NSURL(string: json["image"].string!)
                let data = NSData(contentsOfURL: url!)
                profileInfo!.image = UIImage(data: data!)
                completion(result: profileInfo!)
        }
    }
    
}