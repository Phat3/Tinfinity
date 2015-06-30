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
    
    @IBOutlet weak var profilePict: UIImageView!
    
    //Variabile contenente le informazioni dell'utente
    var profile: User?
    
    var api: ServerAPIController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginButton.delegate = self
        
        profilePict.image = account.pictures[0]
        profilePict.layer.borderWidth = 2
        profilePict.layer.masksToBounds = false
        profilePict.layer.borderColor = UIColor.whiteColor().CGColor
        profilePict.layer.cornerRadius = profilePict.frame.height/2
        profilePict.clipsToBounds = true
        
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
