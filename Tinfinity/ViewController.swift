//
//  ViewController.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import Alamofire
import Socket_IO_Client_Swift
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var profile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //inizializzazione mappa
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //DEBUG
        
        var chat = ChatComunicaction()
        
        chat.connectToServer();
        
        
        /*
        var testo = "ciao come va?"
        
        println("Testo in chiaro : \(testo)")
        
        var cryptoAPI = Crypto()
        
        var cipher: [UInt8] = cryptoAPI.RSAEncrypt(testo)
        

        //creiamo un oggetto data con i byte del chipher e encodiamolo in base64 cosi da poter essere mandato come stringa
        var base64 = NSData(bytes: cipher, length: cipher.count).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        //creaimo un oggetto data partendo da una stringa encodata in base64 (ricaviamo i byte del cipher originale)
        let base64dec = NSData(base64EncodedString: base64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
        //prepariamo il buffer da riempire
        var buffer = [UInt8]()
        //referenza ai byte del cipher
        let bytes = UnsafePointer<UInt8>(base64dec.bytes)
        //riempiamo il buffer
        for i in 0 ..< base64dec.length
        {
            buffer.append(bytes[i])
        }
        println(buffer)

        //decrypt del cipher
        var plain: String = cryptoAPI.RSADecrypt(buffer)
        
        println("Testo decriptato : \(plain)")
        */
        
        /*

        Alamofire.request(.POST, "http://local.tinfinity.com/prova", parameters: ["foo": base64])
            .responseString { (_, _, string, _) in
                println(string!)
            }
            .responseJSON { (_, _, JSON, _) in
                println(JSON!)
            }

        */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Metodi per la posizione sulla mappa
    
    @IBOutlet weak var titleItem: UIBarButtonItem!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var chatButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                var location:CLLocationCoordinate2D = manager.location.coordinate
                
                let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
                self.mapView.setRegion(region, animated: true)
                
                self.displayLocationInfo(pm)
                self.mapView.showsUserLocation = true
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            //locationManager.stopUpdatingLocation()
            
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            println(locality)
            println(postalCode)
            println(administrativeArea)
            println(country)
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        let alertController = UIAlertController(title: "TinFinity", message:
            "Error while updating location!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        println("Error while updating location " + error.localizedDescription)
    }

    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToSettings") {
            var settingsViewcontroller = segue.destinationViewController as! SettingsViewController;
            settingsViewcontroller.profile = self.profile
        }
    }


}

