//
//  FacebookAPIController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 06/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

protocol FacebookAPIControllerProtocol {
    func didReceiveFacebookAPIResults(results: [Album])
}

class FacebookAPIController {
    
    var delegate: FacebookAPIControllerProtocol?
    var albums =  [Album]()
    
    func fetchAlbums(){
        
        let request = FBSDKGraphRequest(graphPath: "me/albums",parameters: nil)
        
        request.startWithCompletionHandler(fbAlbumRequestHandler)
    }
    
    func fbAlbumRequestHandler(connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!){
            
            if let gotError = error{
                println(gotError.description);
            }
            else{
                let graphData = result.objectForKey("data") as! NSArray
                for item in graphData{
                    let obj = item as! NSDictionary
                    
                    let name = obj.valueForKey("name") as! String
                    println(name)
                    var cover = ""
                    if let existsCoverPhoto : AnyObject = obj.valueForKey("cover_photo"){
                        let coverLink = existsCoverPhoto  as! String
                        cover = "/\(coverLink)/photos"
                    }
                    
                    //println(coverLink);
                    let link = obj.valueForKey("link") as! String
                    
                    let model = Album(name: name, link: link, cover:cover);
                    albums.append(model);
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName("albumNotification", object: nil, userInfo: ["data":albums]);
                self.delegate?.didReceiveFacebookAPIResults(albums)
            }
    }
        
        /*func fetchPhoto(link:String){
        let fbRequest = FBRequest.requestForMe();
        fbRequest.graphPath = link;
        fbRequest.startWithCompletionHandler(fetchPhotosHandler);
        }
        
        func fetchPhotosHandler(connection:FBGraphRequestConnection!, result:AnyObject!, error:NSError!){
        if let gotError = error{
        
        }
        else{
        var pictures = [UIImage]();
        let graphData: Array = result.valueForKey("data") as! Array;
        var albums =  [AlbumModel]();
        for obj:FBGraphObject in graphData{
        println(obj.description);
        let pictureURL = obj.valueForKey("picture") as! String;
        let url = NSURL(string: pictureURL);
        let picData = NSData(contentsOfURL: url);
        let img = UIImage(data: picData);
        pictures.append(img);
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("photoNotification", object: nil, userInfo: ["photos":pictures]);
        }
        }*/
}