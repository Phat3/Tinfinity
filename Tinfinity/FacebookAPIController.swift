//
//  FacebookAPIController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 06/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation
import FBSDKCoreKit

protocol FacebookAPIControllerProtocol {
    func didReceiveFacebookAPIResults(results: [Album])
}

class FacebookAPIController {
    
    var delegate: FacebookAPIControllerProtocol?
    var albumsSource =  [Album]()
    var albumsDestination = [Album]()
    
    func fetchAlbums(){        
        
        let requestAlbumId = FBSDKGraphRequest(graphPath: "me/albums",parameters: nil)
            
        requestAlbumId.startWithCompletionHandler(self.fbAlbumRequestHandler)
        
    }
    
    func fbAlbumRequestHandler(connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!){
            
            if let gotError = error{
                println(gotError.description);
            }
            else{
                let graphData = result.objectForKey("data") as! NSArray
                for item in graphData{
                    let obj = item as! NSDictionary
                    
                    let albumName = obj.valueForKey("name") as! String
                    let albumId = obj.valueForKey("id") as! String
                    let model = Album(id: albumId, name: albumName)
                    albumsSource.append(model)
                }
                self.fbCoverRetrivalHelper()
        	}
    }
    
    func fbCoverRetrival(connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!){
        
        if let gotError = error{
            println(gotError.description);
        }
        else{
            let graphData = result.objectForKey("data") as! NSDictionary
            let coverLink = graphData.valueForKey("url") as! String
            let model = Album(id: albumsSource[0].id, name: albumsSource[0].name)
            model.cover = coverLink
            albumsDestination.append(model)
            albumsSource.removeAtIndex(0)
            self.fbCoverRetrivalHelper()
            
        }
    }
    
    
    //This helper function is used to sync the retrival of all album cover with the previous handler(fbAlbumRequestHandler) that fetched the album id(needed for the cover)
    func fbCoverRetrivalHelper(){
        
        if(albumsSource.count != 0){
            
            let requestCover = FBSDKGraphRequest(graphPath: "/\(albumsSource[0].id)/picture?redirect=false", parameters: nil)
            
            requestCover.startWithCompletionHandler(fbCoverRetrival)
            
        }
        else{
                delegate?.didReceiveFacebookAPIResults(albumsDestination)
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