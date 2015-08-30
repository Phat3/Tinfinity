import ObjectiveC.NSObject

let account = Account()

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
}
