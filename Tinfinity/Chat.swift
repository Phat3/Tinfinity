import Foundation.NSDate
import JSQMessagesViewController

var dateFormatter = NSDateFormatter()

class Chat {
    let user: User
    var lastMessageText: String
    var lastMessageSentDate: NSDate
    var lastMessageSentDateString: String {
    return formatDate(lastMessageSentDate)
    }
    var loadedMessages = [JSQMessage]()
    var allMessages = [JSQMessage]()
    var unreadMessageCount: Int = 0 // subtacted from total when read
    var hasUnloadedMessages = false
    var draft = ""

    init(user: User, lastMessageText: String, lastMessageSentDate: NSDate) {
        self.user = user
        self.lastMessageText = lastMessageText
        self.lastMessageSentDate = lastMessageSentDate
    }

    func formatDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()

        let last18hours = (-18*60*60 < date.timeIntervalSinceNow)
        let isToday = calendar.isDateInToday(date)
        let isLast7Days = (calendar.compareDate(NSDate(timeIntervalSinceNow: -7*24*60*60), toDate: date, toUnitGranularity: .CalendarUnitDay) == NSComparisonResult.OrderedAscending)

        if last18hours || isToday {
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
        } else if isLast7Days {
            dateFormatter.dateFormat = "ccc"
        } else {
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .NoStyle
        }
        return dateFormatter.stringFromDate(date)
    }
    
    func reorderChat(){
        /*Insertion Sort*/
        /*for i = 2:n,
        for (k = i; k > 1 and a[k] < a[k-1]; k--)
        swap a[k,k-1]*/
        
        for(var i = 1; i < self.allMessages.count; i++){
            
            for(var k = i; k > 0 && self.allMessages[k - 1].date.timeIntervalSinceDate(self.allMessages[k].date) > 0; k--){
                
                let temp = allMessages[k-1]
            	allMessages[k-1] = allMessages[k]
                allMessages[k] = temp
            }
        }
        lastMessageText = allMessages[allMessages.count-1].text
        lastMessageSentDate = allMessages[allMessages.count-1].date
        
    }
    
    func updateLastMessage(){
        lastMessageSentDate = allMessages[allMessages.count-1].date
        lastMessageText = allMessages[allMessages.count-1].text
        println(lastMessageText)
    }
    
   /*func fetchNewMessages(){
    
    let manager = Alamofire.Manager.sharedInstance
    
    for(var i = 0; i < account.chats ;i++)
        
        manager.request(.GET, baseUrl + "/api/chat/" +  , encoding : .JSON)
            .responseJSON { (request, response, data, error) in
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error!.localizedDescription)
                }else{
                    
                    var json = JSON(data!)
                    let length = json.count
                    
                    for(var i = 0; i < length; i++ ){
                        
                        let innerData = json[i]
                        let user1 = innerData["_id"]["user1"].string
                        let user2 = innerData["_id"]["user2"].string
                        
                        var newUser: User
                        let user1MessagesCount = innerData["user1"].count
                        let user2MessagesCount = innerData["user2"].count
                        let minute: NSTimeInterval = 60, hour = minute * 60, day = hour * 24
                        let date = NSDate(timeIntervalSinceNow: -minute)
                        
                        if (user1 == account.user.userId){
                            //Creiamo un nuovo oggetto user che ha come utente l'id di user2, poichè entrati in questo if user1 coincide con l'id utente dell'accunt in uso. Altrimenti inizializziamo l'user con id user1
                            newUser = User(userId: user2!,firstName: "",lastName: "")
                            // Retrieve user data
                            newUser.fetch();
                        }else{
                            newUser = User(userId: user1!,firstName: "",lastName: "")
                            // Retrieve user data
                            newUser.fetch();
                        }
                        var newChat = Chat(user: newUser,lastMessageText: "",lastMessageSentDate: date)
                        
                        for(var k = 0 ; k < user1MessagesCount; k++){
                            
                            newChat.allMessages.append(self.createJSQMessage(user1!, localMessage: innerData["user1"][k]))
                            
                        }
                        for (var k = 0; k < user2MessagesCount; k++){
                            
                            newChat.allMessages.append(self.createJSQMessage(user2!, localMessage: innerData["user2"][k]))
                            
                        }
                        newChat.reorderChat()
                        account.chats.append(newChat)
                    }
                    
                }
                
        }

    }*/
    
}
