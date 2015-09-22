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
    func didReceiveFacebookPhoto(results: [IdAndImage])
}

protocol FacebookAPIControllerFullPhotoProtocol{
    func didReceiveFacebookFullPhoto(results: UIImage)
}

class FacebookAPIController {
    
    var delegate: FacebookAPIControllerProtocol?
    var photoDelegate: FacebookAPIControllerPhotoProtocol?
    var fullPhotoDelegate: FacebookAPIControllerFullPhotoProtocol?
    var albumsSource =  [Album]()
    var albumsDestination = [Album]()
    var photos = [IdAndImage]()    
    
    func fetchAlbums(){        
        
        let requestAlbumId = FBSDKGraphRequest(graphPath: "me/albums",parameters: nil)
            
        requestAlbumId.startWithCompletionHandler(self.fbAlbumRequestHandler)
        
    }
    
    func fbAlbumRequestHandler(connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!){
            
            if let gotError = error{
                print(gotError.description);
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
            print(gotError.description);
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
    

    func fetchPreviewPhoto(id:String){
        
        let link = "\(id)/photos?fields=picture"
        let requestPhotoId = FBSDKGraphRequest(graphPath: link,parameters: nil)//["fields": "photos{images}"])
            
        requestPhotoId.startWithCompletionHandler(self.fetchPreviewPhotosHandler)
            
    }
        
    func fetchPreviewPhotosHandler(connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!){
        if let gotError = error{
            print(gotError.description)
            }
        else{
            let data = result.valueForKey("data") as! NSArray
            let paging = result.valueForKey("paging") as! NSDictionary
            for obj in data{//each object in the data array contains the preview and id fields of the foto
                let pictureURL = obj.valueForKey("picture") as! String
                let pictureId = obj.valueForKey("id") as! String
                let url = NSURL(string: pictureURL)
                let picData = NSData(contentsOfURL: url!)
                let img = UIImage(data: picData!)
                let bridgeVar = IdAndImage(id: pictureId, image: img!)
                photos.append(bridgeVar)
            }
            if let next = paging.valueForKey("next") as? String
                {
                    let newLink = self.removeFBGraphHeader(next)
                    
                    let requestPhotoIdNext = FBSDKGraphRequest(graphPath: newLink,parameters: nil)
                    
                    requestPhotoIdNext.startWithCompletionHandler(self.fetchPreviewPhotosHandler)
            	}
            photoDelegate?.didReceiveFacebookPhoto(photos)
        }
    }
    
    func fetchFullPhotos(id:String){
        let link = "\(id)?fields=images"
        let requestPhotoUrl = FBSDKGraphRequest(graphPath: link,parameters: nil)
        
        requestPhotoUrl.startWithCompletionHandler(self.fetchFullPhotosHandler)
    }
    
    func fetchFullPhotosHandler(connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!){
        if let gotError = error{
            print(gotError.description)
        }
        else{
            let images = result.valueForKey("images") as! NSArray
            //There should be only one object, which contains the multiple format of the image. We will take the bigger one
            let pictureURL = images[0].valueForKey("source") as! String
            let url = NSURL(string: pictureURL)
            let picData = NSData(contentsOfURL: url!)
            let img = UIImage(data: picData!)
            
        fullPhotoDelegate?.didReceiveFacebookFullPhoto(img!)
        }
    }
    
    //This function is used to remove an unwanted part of the facebook graph api link in order to fetch sequent album's photos
    func removeFBGraphHeader(link:String)->String{
        
        let pattern = "(https://graph.facebook.com/v)[0-9].[0-9]/" //this patterns checks for the presence of the string:
        //https://graph.facebook.com/v) and two numbers divided by a . (which represent the version of the graph API)
        
        let range = NSMakeRange(0, link.characters.count)
        
        let mutableLink:NSMutableString = ""
        mutableLink.appendString(link)
        let regexp = try? NSRegularExpression(pattern: pattern,options: [])
        regexp?.replaceMatchesInString(mutableLink, options: [], range: range, withTemplate: "")
        let newLink: String = mutableLink as String
        return newLink
    }
}