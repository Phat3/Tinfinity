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
import SocketIOClientSwift
import MapKit
import CoreLocation
import Foundation
import AVFoundation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    var profile: User?
    var timer: NSTimer?
    var popover: UIPopoverController? = nil
    
    //Weak reference to parent pageViewController needed for buttons action
    weak var pageViewController: PageViewController?
    
    //Metodi per la posizione sulla mappa
    
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var titleItem: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var chatButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    //the value of the max visible area in the map view
    //roughly 400m (111km : 1deg = 0.4km : xdeg)
    let maximumSpan : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.0036, longitudeDelta: 0.0036)
    //max distance from center to up-left corner of the visible map
    let maximumDistance : CLLocationDistance = 400
    
    //--------- VIEW DELEGATE ---------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 246/255, blue: 243/255, alpha: 1)
        
        // Check if permissions are given
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                
                // Set the timer every 15 seconds
                timer =  NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("refreshLocation"), userInfo: nil, repeats: true)
                
                // Get first location
                refreshLocation()
            }
        } else if(status == CLAuthorizationStatus.NotDetermined) {
            // Require Location Permissions
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Hide the map
            self.blockView.hidden = false;
        }
        
        // We don't want our user to mess with the map
        self.mapView.scrollEnabled = false;
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshLocation()
    }
    
    //--------- END VIEW DELEGATE ---------//

    
    //--------- LOCATIONMANAGER DELEGATE ---------//
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alertController = UIAlertController(title: "Tinfinity", message:
            "Error while updating location!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        print("Error while updating location " + error.localizedDescription, terminator: "")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(account.token != nil) {
            // Lets first update our Model
            let location: CLLocation = locations.last!
            account.setLocation(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude ))
            
            if let location = account.user.position {
                let region = MKCoordinateRegion(center: location, span: self.maximumSpan)
                self.mapView.setRegion(region, animated: true)
                
                // Until we add our nicely designer marker, lets use Apple one
                self.mapView.showsUserLocation = true
                
                // Stop tracking until next call
                locationManager.stopUpdatingLocation()
                self.plotUsersToMap()
            }
        }
    }
    
    //--------- END LOCATIONMANAGER DELEGATE ---------//
    
    
    
    //--------- MAPVIEW DELEGATE ---------//
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //get the visible map area
        let mapRect : MKMapRect = self.mapView.visibleMapRect;
        //get the up-left corner coordinates
        let cornerPoint : MKMapPoint = MKMapPointMake(mapRect.origin.x, mapRect.origin.y);
        //get the center coordinates
        let centerPoint : MKMapPoint = MKMapPointForCoordinate(mapView.centerCoordinate);
        //if the distance from the center (our location) and the up-left corner of the visible map is greater than the max allowed
        //then zoom in to the initial position
        if(MKMetersBetweenMapPoints(cornerPoint, centerPoint) > self.maximumDistance){
            // Avoid possible rush condition
            if let center = locationManager.location?.coordinate {
                self.mapView.setRegion(MKCoordinateRegion(center: center, span: self.maximumSpan), animated: true)
            } else {
                // Milano
                let center = CLLocationCoordinate2D(latitude: ("45.4718727" as NSString).doubleValue, longitude: ("9.1925188" as NSString).doubleValue)
                self.mapView.setRegion(MKCoordinateRegion(center: center, span: self.maximumSpan), animated: true)
            }
        }
        
    }
    
    //--------- END MAPVIEW DELEGATE ---------//
    
    
    //--------- MAP ANNOTATION METHODS ---------//
    
    func plotUsersToMap(){
        //Adding new user annotations
        for(var i = 0; i < account.users.count; i++){
            var found = false
            for annotation in mapView.annotations{
                if let userAnn = annotation as? UserAnnotation{
                    if(userAnn.user.userId == account.users[i].userId){
                        found = true
                    }
                }
            }
            if(!found){
            	let dropPin = UserAnnotation(user: account.users[i])
            	mapView.addAnnotation(dropPin)
            }
        }
    }
    
    /*
     * We don't need to keep refreshing the location all the time, hence we 
     * use 2 minute timer.
     */
    func refreshLocation(){
        locationManager.startUpdatingLocation()
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
        	let rect = AVMakeRectWithAspectRatioInsideRect(img.size, CGRect(x: 0, y: 0, width: 90, height: 90))
        	UIGraphicsBeginImageContext(rect.size)
        	img.drawInRect(rect) //[image drawInRect:rect];
        	let image = UIGraphicsGetImageFromCurrentImageContext()
            let imageData = UIImagePNGRepresentation(image)
            UIGraphicsEndImageContext()
            let finalImage = UIImage(data: imageData!)
            let imageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
            imageView.image = finalImage
            imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = CGFloat(4)
            imageView.layer.borderColor = UIColor.whiteColor().CGColor
            annotationView!.addSubview(imageView)
        	annotationView!.frame = CGRect(origin: CGPointZero, size: imageView.frame.size)
    		return annotationView
        }
    
    	return nil
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? UserAnnotation {
            annotationClicked(annotation)
        }
       
    }
    
    func annotationClicked(annotation: UserAnnotation){
        
        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("profileController") as! ProfileViewController
        profileViewController.user = annotation.user
        profileViewController.navigationPageViewController = self.pageViewController
        profileViewController.cameFromMap = true
        self.presentViewController(profileViewController, animated: true, completion: nil)
        
    }
    
    //--------- END MAP ANNOTATION METHODS ---------//
    
    
    @IBAction func chatButtonClicked(sender: AnyObject) {
        
        let newViewController = self.pageViewController!.viewControllerAtIndex(2)
        self.pageViewController!.setViewControllers([newViewController], direction: .Forward, animated: true,completion: nil)
    }
    
    @IBAction func settingsButtonClicked(sender: AnyObject) {
        
        let newViewController = self.pageViewController!.viewControllerAtIndex(0)
        self.pageViewController!.setViewControllers([newViewController], direction: .Reverse, animated: true,completion: nil)

        
    }
    

    
    
}
