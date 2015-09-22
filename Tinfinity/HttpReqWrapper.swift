//
//  HttpReqWrapper.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 19/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation

import Alamofire

/*
protocol HttpReqWrapperProtocol {
    
    /// called when a POST request have the results ready
    func didReceivePostResult(results: NSDictionary)
    /// called when a GET request have the results ready
    func didReceiveGetResult(results: NSDictionary)

}
*/

class HttpReqWraper {
    /*
    var delegate : HttpReqWrapperProtocol
    
    /// Is possible to instantiate this object only if we specify the delegate class that will handle the results
    init(delegate : HttpReqWrapperProtocol){
        
        self.delegate = delegate
        
    }
*/
    
    /*func post(path : String, params : NSDictionary){
        let baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String;
        Alamofire.request(.POST, baseUrl + path, parameters: params as? [String : AnyObject], encoding : .JSON)
            .responseString {  (request, response, data, error) in
                print("IN METODO STRING")
                print("RESPONSE")
                print(response)
                print("DATA")
                print(data)
                print("ERROR")
                print(error)
            }
            .responseJSON { (request, response, data, error) in
                print("IN METODO JSON")
                print("RESPONSE")
                print(response)
                print("DATA")
                print(data)
                print("ERROR")
                print(error)
            }
            /*
            .response { (request, response, data, error) in
                println("RESPONSE")
                println(response)
                println("DATA")
                println(data)
                println("ERROR")
                println(error)
        }
*/

        
    }
*/    
}