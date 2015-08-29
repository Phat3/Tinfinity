import ObjectiveC.NSObject

let account = Account()
let MAX_PHOTOS = 6

class Account: NSObject {
    var user: User!
    dynamic var token: String!
    var users = [User]()
    var chats = [Chat]()
    var pictures = [UIImage?](count: MAX_PHOTOS, repeatedValue:nil )

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
}
