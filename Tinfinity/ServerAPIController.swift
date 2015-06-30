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
    let chatListPath: String
    var tinfinityToken: String?
    
    init(FBAccessToken: String){
        FBToken = FBAccessToken
        baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String
        authenticationPath = NSBundle.mainBundle().objectForInfoDictionaryKey("Authentication Path") as! String
        chatListPath = NSBundle.mainBundle().objectForInfoDictionaryKey("Chat List Path") as! String
    }
    
    //Funzione che chiama il server e setta i parametri dell'utente. Ritorna true se la richiesta è andata a buon fine,altrimenti false
    func retrieveProfileFromServer(completion: (result: Bool) -> Void){
            
            Alamofire.request(.POST, baseUrl + authenticationPath, parameters: ["token" : FBToken], encoding : .JSON)
                .responseJSON { (request, response, data, error) in
                    
                    if(error != nil) {
                        // If there is an error in the web request, print it to the console
                        println(error!.localizedDescription)
                
                        completion(result: false)
                    }else{
                    
                    var json = JSON(data!)
                    
                    let id = json["_id"].string
                    let name = json["name"].string
                    let surname = json["surname"].string
                    self.tinfinityToken = json["token"].string
                    //Settiamo per tutta la sessione il manger alamofire affinche abbia il token nell'header per l'autenticazione in tutte le chiamate al server
                    let manager = Alamofire.Manager.sharedInstance
                    manager.session.configuration.HTTPAdditionalHeaders = ["X-Api-Token": self.tinfinityToken!]
                        
                    let url = NSURL(string: json["image"].string!)
                    let data = NSData(contentsOfURL: url!)
                    account.pictures.append(UIImage(data: data!)!)
                    
                    account.user = User(userId: id!, firstName: name!, lastName: surname!)
                    account.user.email = json["email"].string
                    
                    completion(result: true)
            		}
       			 }
    }

    func retriveChatHistory(id: String, completion: (result: [(Chat)] ) -> Void){
        
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, baseUrl + "/api/chat", encoding : .JSON)
            .responseJSON { (request, response, data, error) in
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error!.localizedDescription)
                }else{
                    var json = JSON(data!)
                    
                    println(data!)
                
                }
        }
    }
    
}