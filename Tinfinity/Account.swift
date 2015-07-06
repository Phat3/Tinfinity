import ObjectiveC.NSObject

let account = Account()
let MAX_PHOTOS = 6

class Account: NSObject {
    var user: User!
    dynamic var accessToken: String!
    var users = [User]()
    var chats = [Chat]()
    var pictures = [UIImage?](count: MAX_PHOTOS, repeatedValue:nil )

    func logOut() {
        accessToken = nil
        user = nil
    }

    func deleteAccount() {
        logOut()
    }
}
