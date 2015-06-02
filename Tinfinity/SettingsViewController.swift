//
//  SettingsViewController.swift
//  
//
//  Created by Alberto Fumagalli on 20/05/15.
//
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var profilePict: FBSDKProfilePictureView!
    
    //Variabile contenente le informazioni dell'utente
    var profile: User?
    
    var api: ServerAPIController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginButton.delegate = self
        
        var frame = profilePict.frame
        let imageSize = 80 as CGFloat
        frame.size.height = imageSize
        frame.size.width  = imageSize
        profilePict.frame = frame
        profilePict.layer.cornerRadius = imageSize / 2.0
        profilePict.clipsToBounds = true
        
        //instatiating the apicontroller with the current access token to authenticate with the server
        /*api = ServerAPIController(FBAccessToken: FBSDKAccessToken.currentAccessToken().tokenString)
        
        api?.retrieveProfileFromServer({ (result) -> Void in
            self.profile = result
            self.firstName.text = self.profile!.firstName
            self.lastName.text = self.profile!.lastName
            self.spinner.stopAnimating()
        })*/
        if(account.user != nil){
            self.firstName.text = account.user.firstName
            self.lastName.text = account.user.lastName
            self.spinner.stopAnimating()
        }
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 246/255, blue: 243/255, alpha: 1)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        account.user = nil
        performSegueWithIdentifier("logoutExecuted", sender: self)
    }
    
}
