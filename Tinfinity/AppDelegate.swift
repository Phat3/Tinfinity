//
//  AppDelegate.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //registerting for the notification.
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        
        //Register to pushbot
        Pushbots.sharedInstanceWithAppId("56179eb117795989018b4567")
        
        //Handle notification when the user click it, while app is closed.
        // Reset badge on the server and in the app.
        Pushbots.sharedInstance().clearBadgeCount()
        
        var result = UIScreen.mainScreen().bounds.size
    	let scale = UIScreen.mainScreen().scale
        result = CGSizeMake(result.width*scale, result.height*scale)
        if (result.height == 960) {//iPh4/4S
        	let storyboard = UIStoryboard(name:"Main5", bundle: nil)
            let initViewController = storyboard.instantiateInitialViewController() as! LoginViewController
        	self.window?.rootViewController = initViewController
    	}else if (result.height == 1136) { //iPh5/5C/5S
            let storyboard = UIStoryboard(name:"Main5", bundle: nil)
            let initViewController = storyboard.instantiateInitialViewController() as! LoginViewController
            self.window?.rootViewController = initViewController
        }else if (result.height == 1334) { //iPh6
            let storyboard = UIStoryboard(name:"Main6", bundle: nil)
            let initViewController = storyboard.instantiateInitialViewController() as! LoginViewController
            self.window?.rootViewController = initViewController
        }else if (result.height == 2208) { //iPh6+
            let storyboard = UIStoryboard(name:"Main6p", bundle: nil)
            let initViewController = storyboard.instantiateInitialViewController() as! LoginViewController
            self.window?.rootViewController = initViewController
        }
               return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        /*
         * E' il modo corretto di gestire la cosa?
         *
        account.refreshRelationships { (result) -> Void in
            
        }
         */
        
        /*
         * Non un buon approccio, in quanto se siamo dentro una chat,
         * crea problemi con i sockets
         * Idea: controllare che la view attiva non sia quella in cui è attivo il socket, quindi che sia la chatlist o la chatview
		*/
        print("Ricevuta notifica push")
        let topController = UIApplication.topViewController()
        var actualControllerId: String = ""
        if let page = topController as? UIPageViewController {
            //Troviamo il restoration id del primo controller
            actualControllerId = (page.viewControllers?[0].restorationIdentifier)!
        }
        //Controlliamo che non sia un page, oppure se lo è che il primo non sia il right
        if !(topController is PageViewController) || (actualControllerId != "rightViewController"){
            //Dobbiamo togliere la possibilità che ci si trovi in un profileController non creato da mapKit
            if let profileView = topController as? ProfileViewController {
                if(profileView.cameFromMap){
                    account.refreshChats { (result) -> Void in
                    }
                }
                
            }else{
        		account.refreshChats { (result) -> Void in
        		}
            }
        }

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        
        // Refresh relationships
        account.refreshRelationships { (result) -> Void in
            
        }
        
        //If there is a logged used, we need to check if we received messages while the app was in teh background(push notification only show the notification, they do not carry data in our app)
        account.refreshChats { (result) -> Void in

        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()        
	}
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ChatsModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Tinfinity.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    //PUSHBOT
    
    //Function used to register for remote notifications
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // This method will be called everytime you open the app
        // Register the deviceToken on Pushbots
        Pushbots.sharedInstance().registerOnPushbots(deviceToken);
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Notification Registration Error.");
    }
	
}

