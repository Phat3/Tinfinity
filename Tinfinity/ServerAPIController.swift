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
    
    //Funzione che chiama il server e setta i parametri dell'utente. Ritorna true se la richiesta è andata a buon fine,altrimenti false
    func retrieveProfileFromServer(completion: (result: User) -> Void){
            
            Alamofire.request(.POST, baseUrl + authenticationPath, parameters: ["token" : FBToken], encoding : .JSON)
                .responseJSON { (request, response, data, error) in
                    
                    if(error != nil) {
                        // If there is an error in the web request, print it to the console
                        println(error!.localizedDescription)
                    }else{
                    
                    var json = JSON(data!)
                    
                    let id = json["userId"].string;
                    let name = json["name"].string;
                    let surname = json["surname"].string;
                    
                    //Per il momento l'user id non è ritornato dal server e lo mettiamo manualmente
                    account.user = User(userId: "1", firstName: name!, lastName: surname!)
                    account.user.email = json["email"].string;
                    
                    
                    //Non necessario siccome l'immagine profilo viene presa dall'apposita view di facebook e per gli altri utenti vengono caricate al momento dell'apertura della chat
                    /*let url = NSURL(string: json["image"].string!)
                    let data = NSData(contentsOfURL: url!)
                    profileInfo!.image = UIImage(data: data!)*/
            		}
       			 }
    }
    
}