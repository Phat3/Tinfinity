import ObjectiveC.NSObject
import Alamofire
import SwiftyJSON

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
     * Con questo metodo, pushamo le informazioni relative all'utente 'me' in remoto
     */
    func sync() {
        
    }

    func deleteAccount() {
        logOut()
    }
    
    func fetchNearbyUsers(){
        
        let manager = Alamofire.Manager.sharedInstance
        
        if let userPosition = self.user.position{
        
        	Alamofire.request(.POST, baseUrl + "/api/users", parameters: ["lat" : userPosition.coordinate.latitude, "lon": userPosition.coordinate.longitude], encoding : .JSON)
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
                            
                            let userPosition = CLLocation(latitude: position["latitude"].double!, longitude: position["longitude"].double!)
                            
                            newUser.position = userPosition
                            self.users.append(newUser)
                        }
            	    }
        	}
        }
        println(self.users)
    }
    
    func setLocation(location: CLLocation){
        //Passando oggetto CLLocation, setta account.user.location e poi fa chiamata di ping al server
        account.user.position = location
        
        self.fetchNearbyUsers()
    }
}
