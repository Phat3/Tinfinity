//
//  ViewController.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//  @author Sebastiano Mariani
//

import UIKit
import Alamofire
import Socket_IO_Client_Swift
import MapKit
import CoreLocation
import Foundation
import AVFoundation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var profile: User?
    var timer: NSTimer?
    
    //Weak reference to parent pageViewController needed for buttons action
    weak var pageViewController: PageViewController?
    
    //Metodi per la posizione sulla mappa
    
    @IBOutlet weak var titleItem: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var chatButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 246/255, blue: 243/255, alpha: 1)
        
        // Require Location Permissions
        locationManager.requestWhenInUseAuthorization()
        
        // Check if permissions are given
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            // Set the timer every 2 minutes
            timer =  NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: Selector("refreshLocation"), userInfo: nil, repeats: true)
            
            // Get first location
            refreshLocation()
            
        } else {
            //@TODO Block App
        }
        
        // We don't want our user to mess with the map
        self.mapView.zoomEnabled = true;
        self.mapView.scrollEnabled = false;
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Lets first update our Model
        let location: CLLocation = locations.last!
        account.setLocation(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude ))
        
        if let location = account.user.position {
            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            self.mapView.setRegion(region, animated: true)
        
            // Until we add our nicely designer marker, lets use Apple one
            self.mapView.showsUserLocation = true
            
            // Stop tracking until next call
            locationManager.stopUpdatingLocation()
            self.plotUsersToMap()
        }
    }
    
    func plotUsersToMap(){
        for(var i = 0; i < account.users.count; i++){
            let dropPin = UserAnnotation(user: account.users[i])
            mapView.addAnnotation(dropPin)
        }
    }
    
    /*
     * We don't need to keep refreshing the location all the time, hence we 
     * use 2 minute timer.
     */
    func refreshLocation(){
        print("Refreshing Location...", terminator: "");
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alertController = UIAlertController(title: "TinFinity", message:
            "Error while updating location!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        print("Error while updating location " + error.localizedDescription, terminator: "")
    }
    
   func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
    	if (annotation is MKUserLocation) {
        	return nil
    	}
        
    	let reuseId = "Annotation"
    	if annotation is UserAnnotation{
            
    		var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
			if annotationView == nil{
                //If annotationView is nil a new one is created
            	annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            	annotationView!.canShowCallout = true
                
                let calloutButton = UIButton(type: .DetailDisclosure)
                
                annotationView!.rightCalloutAccessoryView = calloutButton
            
    		}
        	else{
                //Else we use this annotationView to show the new annotation
        		annotationView!.annotation = annotation
    		}
            
        	let customAnnotation = annotation as! UserAnnotation
        	
        	let img = ImageUtil.cropToSquare(image: customAnnotation.image)
        	let rect = AVMakeRectWithAspectRatioInsideRect(img.size, CGRect(x: 0, y: 0, width: 35, height: 35))
        	UIGraphicsBeginImageContext(rect.size)
        	img.drawInRect(rect) //[image drawInRect:rect];
        	let image = UIGraphicsGetImageFromCurrentImageContext()
            let imageData = UIImagePNGRepresentation(image)
            UIGraphicsEndImageContext()
            let finalImage = UIImage(data: imageData!)
            let imageView = UIImageView(frame: CGRectMake(0, 0, 35, 35))
            imageView.image = finalImage
            imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
            imageView.layer.masksToBounds = true
            annotationView!.addSubview(imageView)
        	annotationView!.frame = CGRect(origin: CGPointZero, size: imageView.frame.size)
    		return annotationView
    }
    
    	return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("bottone cliccato", terminator: "")
        if let annotation = view.annotation as? UserAnnotation {
            annotationClicked(annotation)
        }
       
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshLocation()
    }
    
    @IBAction func chatButtonClicked(sender: AnyObject) {
        
        let newViewController = self.pageViewController!.viewControllerAtIndex(2)
        self.pageViewController!.setViewControllers([newViewController], direction: .Forward, animated: true,completion: nil)
    }
    
    @IBAction func settingsButtonClicked(sender: AnyObject) {
        
        let newViewController = self.pageViewController!.viewControllerAtIndex(0)
        self.pageViewController!.setViewControllers([newViewController], direction: .Reverse, animated: true,completion: nil)

        
    }
    
    func annotationClicked(annotation: UserAnnotation){
        
        let newViewController = self.pageViewController!.viewControllerAtIndex(2) as! UINavigationController
        
        let chatListController = newViewController.topViewController as! ChatListViewController
        
        if let _ = Chat.getChatByUserId(annotation.user.userId).0{
                chatListController.newChat = false
                chatListController.clickedUserId = annotation.user.userId
            }else{
                chatListController.newChat = true
                account.chats.insert(Chat(user: annotation.user, lastMessageText: "", lastMessageSentDate: NSDate()), atIndex: 0)
        }
        
        self.pageViewController!.setViewControllers([newViewController], direction: .Forward, animated: true,completion: nil)

    }
    
    
}
