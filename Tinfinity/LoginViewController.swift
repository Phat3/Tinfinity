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
    
    var api: ServerAPIController?
    var profile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginButton.delegate = self
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            // Process error
            println("Errore")
        }
        else if result.isCancelled {
            // Handle cancellations
            println("cancelled")
        }
        else {
            // Navigate to other view
            println("Funzione 2")
            api = ServerAPIController(FBAccessToken: FBSDKAccessToken.currentAccessToken().tokenString)
            api?.retrieveProfileFromServer({ (result) -> Void in
                self.profile = result
            })
            performSegueWithIdentifier("loginExecuted", sender: self)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
       
    }
       
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Controlliamo se è già presente un token facebook
        if (FBSDKAccessToken.currentAccessToken() != nil){
            
            // User is already logged in, do work such as go to next view controller.
            
            //instatiating the apicontroller with the current access token to authenticate with the server
            api = ServerAPIController(FBAccessToken: FBSDKAccessToken.currentAccessToken().tokenString)
            api?.retrieveProfileFromServer({ (result) -> Void in
                self.profile = result
                println(result.firstName)
            })
            performSegueWithIdentifier("loginExecuted", sender: self)
            
        }
        else{            
            loginButton.center = self.view.center
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "loginExecuted") {
            var mainViewcontroller = segue.destinationViewController as! ViewController
        }
    }
}
