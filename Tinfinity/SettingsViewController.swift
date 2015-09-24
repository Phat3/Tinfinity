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
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var profilePict: UIButton!
    
    //Weak reference to parent pageViewController
    weak var pageViewController: PageViewController?
    
    //Variabile contenente le informazioni dell'utente
    var profile: User?
    
    var api: ServerAPIController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginButton.delegate = self
        profilePict.setImage(ImageUtil.cropToSquare(image: account.user.image!),forState: .Normal)
        profilePict.layer.borderWidth = 2
        profilePict.layer.masksToBounds = false
        profilePict.layer.borderColor = UIColor.whiteColor().CGColor
        profilePict.layer.cornerRadius = profilePict.frame.height/2
        profilePict.clipsToBounds = true
        
        if(account.user != nil){
            self.name.text = account.user.name
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
            print("Errore", terminator: "")
        }
        else if result.isCancelled {
            // Handle cancellations
            print("cancelled", terminator: "")
        }
        else {
            // Navigate to other view
            
        }
    }

    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        account.user = nil
        performSegueWithIdentifier("logoutExecuted", sender: self)
    }
    
    @IBAction func homeButtonClicked(sender: AnyObject){
        
        let newViewController = self.pageViewController!.viewControllerAtIndex(1)
        self.pageViewController!.setViewControllers([newViewController], direction: .Forward, animated: true,completion: nil)
        
    }
    
}
