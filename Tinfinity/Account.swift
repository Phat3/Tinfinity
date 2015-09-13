import ObjectiveC.NSObject
import Alamofire
import SwiftyJSON
import CoreData

let account = Account()
let baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String


class Account: NSObject {
    
    // Me
    var user: User!
    
    // API Token
    dynamic var token: String!
    
    // Visible users
    var users = [User]()
    
    // Stored chats
    var chats = [Chat]()

    func logOut() {
        token = nil
        user = nil
    }
    
    /**
     * Con questo metodo, pushamo le informazioni relative alle immagini
     * dell'utente 'me' in remoto
     * Effettuiamo una richiesta HTTP per ogni immagine per non avere body
     * troppo grossi che possono generare dei 413 lato server.
     */
    func pushImages() {
        
        for( var i = 0; i < self.user.images.count ; i++ ) {
            if let imgProfile:NSData = UIImagePNGRepresentation(self.user.images[i]) {
                Alamofire.request(.POST, baseUrl + "/api/users/me/images", parameters: [
                    "image" : i,
                    "imageData" : imgProfile.base64EncodedStringWithOptions(.allZeros)
                ])
            }
        }
    }
    
    /**
     * Con questo metodo, recuperiamo le informazioni relative alle immagini
     * dell'utente 'me' dal server remoto
     */
    func fetchImages() {
        // let base64String = prefs.valueForKey("imgDefault") as? String
        // let decodedData = NSData(base64EncodedString: base64String!, options: NSDataBase64DecodingOptions(rawValue: 0) )
        // var decodedimage = UIImage(data: decodedData!)
    }

    func deleteAccount() {
        logOut()
    }
    
    func fetchNearbyUsers(){
        
        let manager = Alamofire.Manager.sharedInstance
        
        if let userPosition = self.user.position{
        
        	Alamofire.request(.POST, baseUrl + "/api/users", parameters: ["lat" : userPosition.latitude, "lon": userPosition.longitude], encoding : .JSON)
            	.responseJSON { (request, response, data, error) in
                
                	if(error != nil) {
                    	// If there is an error in the web request, print it to the console
                    	println(error!.localizedDescription)
                    
                	}else{
                    
                	    var json = JSON(data!)
                        for(var i = 0; i < json.count; i++){
                            let userData = json[i]["user"]
                            let position = json[i]["position"]
                            var newUser = User(userId: userData["_id"].string!, firstName: userData["name"].string!, lastName: userData["surname"].string!)
                            newUser.fetch({ (result) -> Void in
                                let userPosition = CLLocationCoordinate2D(latitude: position["latitude"].double!, longitude: position["longitude"].double!)
                                
                                newUser.position = userPosition
                                self.users.removeAll(keepCapacity: false)
                                self.users.append(newUser)
                            })                           
                            
                        }
            	    }
        	}
        }
        println(self.users)
    }
    
    func setLocation(location: CLLocationCoordinate2D){
        //Passando oggetto CLLocation, setta account.user.location e poi fa chiamata di ping al server
        if user != nil{
            account.user.position = location
            self.fetchNearbyUsers()
        }        
        
    }
}
