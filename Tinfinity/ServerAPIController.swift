//
//  ServerAPIController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 27/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation

class ServerAPIController{
    
    var FBToken : String
    let authenticationPath: String
    let serverURL: String
    
    init(FBAccessToken: String){
        FBToken = FBAccessToken
        authenticationPath = NSBundle.mainBundle().objectForInfoDictionaryKey("Authentication Path") as! String
        serverURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String
    }
    
    //Funzione che chiama il server e ritorna un'istanza di UserProfile
    func retrieveProfileFromServer(completion: (result: UserProfile) -> Void){
        
        var profileInfo : UserProfile?
        var url: NSURL = NSURL(string: serverURL + authenticationPath)!
        var bodyData = "token=" + FBToken
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                if let json = jsonResult as? Dictionary<String, AnyObject> {
                    if let name = json["name"] as? String {
                        if let surname = json["surname"] as? String {
                            profileInfo = UserProfile(name: name, surname: surname)
                            completion(result: profileInfo!)
                        }
                    }
                }
            }
        }        
        task.resume()
    }
    
}