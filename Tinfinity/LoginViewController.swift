//
//  LoginViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 22/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{
    

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    var api: ServerAPIController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginButton.delegate = self
        self.view.backgroundColor = UIColor(red: 247/255, green: 246/255, blue: 243/255, alpha: 1)
        
        let minute: NSTimeInterval = 60, hour = minute * 60, day = hour * 24
        account.chats = [
            Chat(user: User(userId:"2", firstName: "Matt", lastName: "Di Pasquale"), lastMessageText: "Thatnks for checking out Chats! :-)", lastMessageSentDate: NSDate()),
            Chat(user: User(userId:"3", firstName: "Angel", lastName: "Rao"), lastMessageText: "6 sounds good :-)", lastMessageSentDate: NSDate(timeIntervalSinceNow: -minute)),
            Chat(user: User(userId:"4", firstName: "Valentine", lastName: "Sanchez"), lastMessageText: "Haha", lastMessageSentDate: NSDate(timeIntervalSinceNow: -minute*12)),
            Chat(user: User(userId:"5",firstName: "Ben", lastName: "Lu"), lastMessageText: "I have no profile picture.", lastMessageSentDate: NSDate(timeIntervalSinceNow: -hour*5)),
            Chat(user: User(userId:"6",firstName: "Aghbalu", lastName: "Amghar"), lastMessageText: "Damn", lastMessageSentDate: NSDate(timeIntervalSinceNow: -hour*13)),
            Chat(user: User(userId:"7",firstName: "中文 日本語", lastName: "한국인"), lastMessageText: "I have no profile picture or extended ASCII initials.", lastMessageSentDate: NSDate(timeIntervalSinceNow: -hour*24)),
            Chat(user: User(userId:"8",firstName: "Candice", lastName: "Meunier"), lastMessageText: "I can't wait to see you! ❤️", lastMessageSentDate: NSDate(timeIntervalSinceNow: -hour*34)),
            Chat(user: User(userId:"9",firstName: "Ferdynand", lastName: "Kaźmierczak"), lastMessageText: "http://youtu.be/UZb2NOHPA2A", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*2-1)),
            Chat(user: User(userId:"10",firstName: "Lauren", lastName: "Cooper"), lastMessageText: "Thinking of you...", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*3)),
            Chat(user: User(userId:"11",firstName: "Bradley", lastName: "Simpson"), lastMessageText: "👍", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*4)),
            
        ]
        
        for chat in account.chats {
            account.users.append(chat.user)
        }
        
        for user in account.users{
            user.imageUrl = "http://www.mhodi.it/wp-content/uploads/2012/09/no-user1-300x300.jpg"
        }

        
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
            //instatiating the apicontroller with the current access token to authenticate with the server
            api = ServerAPIController(FBAccessToken: FBSDKAccessToken.currentAccessToken().tokenString)
            api?.retrieveProfileFromServer({ (result) -> Void in})
          
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
            
            //instatiating the apicontroller with the current access token to authenticate with the server
            api = ServerAPIController(FBAccessToken: FBSDKAccessToken.currentAccessToken().tokenString)
            
            api?.retrieveProfileFromServer({ (result) -> Void in})
            let minute: NSTimeInterval = 60, hour = minute * 60, day = hour * 24
            
            // User is already logged in, do work such as go to next view controller.
            performSegueWithIdentifier("loginExecuted", sender: self)
            
        }
        else{            
            loginButton.center = self.view.center
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
        
    }
    
}
