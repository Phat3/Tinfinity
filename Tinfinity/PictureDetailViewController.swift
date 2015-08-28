//
//  PictureDetailViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 21/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class PictureDetailViewController: UIViewController, FacebookAPIControllerFullPhotoProtocol {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var pictureDetail: UIImageView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    let facebookApi = FacebookAPIController()
    var imageId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookApi.fullPhotoDelegate = self
        facebookApi.fetchFullPhotos(imageId)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveFacebookFullPhoto(results: UIImage) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activitySpinner.hidden = true
            self.pictureDetail.image = results
            self.pictureDetail.contentMode = UIViewContentMode.Center
            //if (pictureDetail.bounds.size.width > ((UIImage*)imagesArray[i]).size.width && pictureDetail.bounds.size.height > ((UIImage*)imagesArray[i]).size.height) {
            self.pictureDetail.contentMode = UIViewContentMode.ScaleAspectFit
            //}
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
}
