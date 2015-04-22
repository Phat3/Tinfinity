//
//  LoginViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 22/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{
    

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        titleLabel.text = "Benvenuto in Tinfity!"
        
        //Controlliamo se è già presente un token facebook
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
           let secondView =  self.storyboard!.instantiateViewControllerWithIdentifier("mainViewController") as? ViewController
            self.presentViewController(secondView!, animated: true, completion: nil)
            
        }
        else
        {            
            loginButton.center = self.view.center
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // Navigate to other view
            let secondView =  self.storyboard!.instantiateViewControllerWithIdentifier("mainViewController") as? ViewController
            self.presentViewController(secondView!, animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
