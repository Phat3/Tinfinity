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

protocol FacebookAPIControllerPhotoProtocol{
    func didReceiveFacebookPhoto(results: [UIImage])
}

class FacebookAPIController {
    
    var delegate: FacebookAPIControllerProtocol?
    var photoDelegate: FacebookAPIControllerPhotoProtocol?
    var albumsSource =  [Album]()
    var albumsDestination = [Album]()
    var photos = [UIImage]()
    
    
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
    
    //The function processes the informations obtained via the facebook api call, then saves them locally and removes the first element
    //of the old album array, so that the helper function will call again the api on the next element
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
    
    
    //This helper function always call the graph API on the first element of the array alcumSource. It is up to the Completion Handler to remove
    //the already processed element from the array(the first one as said before), so that all the albums can be processed.
    func fbCoverRetrivalHelper(){
        
        if(albumsSource.count != 0){
            
            let requestCover = FBSDKGraphRequest(graphPath: "/\(albumsSource[0].id)/picture?redirect=false", parameters: nil)
            
            requestCover.startWithCompletionHandler(fbCoverRetrival)
            
        }
        else{
                delegate?.didReceiveFacebookAPIResults(albumsDestination)
            }
        }
    

        func fetchPhoto(id:String){
            
            let link = "\(id)/photos?fields=picture"
            let requestPhotoId = FBSDKGraphRequest(graphPath: link,parameters: nil)
            
            requestPhotoId.startWithCompletionHandler(self.fetchPhotosHandler)
            
        }
        
        func fetchPhotosHandler(connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!){
        	if let gotError = error{
        		println(gotError.description)
       		 }
        	else{
        		let graphData = result.valueForKey("data") as! NSArray
                let paging = result.valueForKey("paging") as! NSDictionary
                for obj in graphData{
        			let pictureURL = obj.valueForKey("picture") as! String
        			let url = NSURL(string: pictureURL)
        			let picData = NSData(contentsOfURL: url!)
        			let img = UIImage(data: picData!)
        			photos.append(img!)
        		}
                if let next = paging.valueForKey("next") as? String
                	{
                        let newLink = self.removeFBGraphHeader(next)
                        
                        let requestPhotoIdNext = FBSDKGraphRequest(graphPath: newLink,parameters: nil)
                        
                        requestPhotoIdNext.startWithCompletionHandler(self.fetchPhotosHandler)
                }
                photoDelegate?.didReceiveFacebookPhoto(photos)
        	}
    	}
    
    //This function is used to remove an unwanted part of the facebook graph api link in order to fetch sequent album's photos
    func removeFBGraphHeader(link:String)->String{
        
        let pattern = "(https://graph.facebook.com/v)[0-9].[0-9]/" //this patterns checks for the presence of the string:
        //https://graph.facebook.com/v) and two numbers divided by a . (which represent the version of the graph API)
        
        let range = NSMakeRange(0, count(link))
        
        var mutableLink:NSMutableString = ""
        mutableLink.appendString(link)
        let regexp = NSRegularExpression(pattern: pattern,options: nil, error: nil)
        regexp?.replaceMatchesInString(mutableLink, options: .allZeros, range: range, withTemplate: "")
        let newLink: String = mutableLink as String
        return newLink
    }
}