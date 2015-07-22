//
//  PictureDetailViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 21/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class PictureDetailViewController: UIViewController {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var pictureDetail: UIImageView!
    
    var supportImage =  UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pictureDetail.image = supportImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
