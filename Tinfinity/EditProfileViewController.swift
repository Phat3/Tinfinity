//
//  EditProfileViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 30/06/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var imageButton3: UIButton!
    @IBOutlet weak var imageButton4: UIButton!
    @IBOutlet weak var imageButton5: UIButton!
    @IBOutlet weak var imageButton6: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttons = [imageButton1,imageButton2,imageButton3,imageButton4,imageButton5,imageButton6]
        for button in buttons{
            let cornerRadius : CGFloat = 5.0
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.cornerRadius = cornerRadius
        }
        var counter = 0
        for (var i = 0; i < MAX_PHOTOS-1; i++){
            if let picture=account.pictures[i]{
                buttons[i].setImage(picture,forState: .Normal)
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}