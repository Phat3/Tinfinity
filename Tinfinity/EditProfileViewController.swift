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
        var counter = 0
        for (var i = 0; i < MAX_PHOTOS-1; i++){
            if let picture=account.pictures[i]{
                switch counter{
                case 0:
                    imageButton1.setImage(picture,forState: .Normal)
                    break
                case 1:
					imageButton2.setImage(picture,forState: .Normal)
                    break
                case 2:
                    imageButton3.setImage(picture,forState: .Normal)
                    break
                case 3:
                    imageButton4.setImage(picture,forState: .Normal)
                    break
                case 4:
                    imageButton5.setImage(picture,forState: .Normal)
                    break
                case 5:
                    imageButton6.setImage(picture,forState: .Normal)
                    break
                default:
                    break
                }
                counter++
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
