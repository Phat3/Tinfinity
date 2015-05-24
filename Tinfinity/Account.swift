import ObjectiveC.NSObject

let account = Account()

class Account: NSObject {
    var user: User!
    dynamic var accessToken: String!
    var users = [User]()
    var chats = [Chat]()

    func logOut() {
        accessToken = nil
        user = nil
    }

    func deleteAccount() {
        logOut()
    }
}
