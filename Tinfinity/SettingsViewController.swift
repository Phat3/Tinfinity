//
//  SettingsViewController.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ageLabel: UILabel!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var profilePict: UIButton!
    
    //Weak reference to parent pageViewController
    weak var pageViewController: PageViewController?
    
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
            if let age = account.user.age {
                self.ageLabel.text = age + " years old"
            } else {
                self.ageLabel.text = "No birthday provided"
            }
            
            self.spinner.stopAnimating()
        }
        self.view.backgroundColor = UIColor(red: 247/255, green: 246/255, blue: 243/255, alpha: 1)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------- FACEBOOK DELEGATE ---------//
        
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
        for(var i = 0; i < account.chats.count; i++){
            account.chats[i].deleteChat()
        }
        account.logOut()
        performSegueWithIdentifier("logoutExecuted", sender: self)
    }
    
    //--------- END FACEBOOK DELEGATE ---------//
    
    @IBAction func homeButtonClicked(sender: AnyObject){
        
        let newViewController = self.pageViewController!.viewControllerAtIndex(1)
        self.pageViewController!.setViewControllers([newViewController], direction: .Forward, animated: true,completion: nil)
        
    }
    
}
