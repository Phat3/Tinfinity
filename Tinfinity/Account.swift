import ObjectiveC.NSObject
import Alamofire
import SwiftyJSON

let account = Account()
let baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String


class Account: NSObject {
    var user: User!
    dynamic var token: String!
    var users = [User]()
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
                        println(json)
                        let userData = json[0]["user"]
                        let position = json[0]["position"]
                        var newUser = User(userId: userData["_id"].string!, firstName: userData["name"].string!, lastName: userData["surname"].string!)
                        let userPosition = CLLocation(latitude: position["latitude"].double!, longitude: position["longitude"].double!)
                        newUser.position = userPosition
                        
                        self.users.append(newUser)
                        
                        println(json)
            	    }
        	}
        }
        
    }
    
    func setLocation(location: CLLocation){
        //Passando oggetto CLLocation, setta account.user.location e poi fa chiamata di ping al server
        account.user.position = location
        
        self.fetchNearbyUsers()
    }
}
