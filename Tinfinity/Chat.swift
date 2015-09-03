import Foundation.NSDate
import JSQMessagesViewController
import Alamofire
import SwiftyJSON

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
    
    let baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String
    let chatListPath = NSBundle.mainBundle().objectForInfoDictionaryKey("Chat List Path") as! String


    init(user: User, lastMessageText: String, lastMessageSentDate: NSDate) {
        self.user = user
        self.lastMessageText = lastMessageText
        self.lastMessageSentDate = lastMessageSentDate
    }
    
    static func getChatByUserId(user_id: String) -> Chat? {
        for(var i=0; i < account.chats.count; i++){
            if (account.chats[i].user.userId == user_id){
                return account.chats[i]
            }
        }
        return nil
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
        updateLastMessage()
        
    }
    
    func updateLastMessage(){
        lastMessageSentDate = allMessages[allMessages.count-1].date
        lastMessageText = allMessages[allMessages.count-1].text
    }
    
    func fetchNewMessages(completion: (result: Bool) -> Void){
        
        let manager = Alamofire.Manager.sharedInstance
            
            //We need the timeinterval to speak with the server, but in milliseconds
            let timeinterval: Double = round(self.lastMessageSentDate.timeIntervalSince1970 * 1000)
        
        	let stringTime = NSString(format: "%.f",timeinterval) as! String
            
            
            manager.request(.GET, baseUrl + "/api/chat/" + self.user.userId + "/" + stringTime , encoding : .JSON)
                .responseJSON { (request, response, data, error) in
                    
                    if(error != nil) {
                        // If there is an error in the web request, print it to the console
                        println(error!.localizedDescription)
                    }else if(response != false){
                        var innerData = JSON(data!)
                        
                            let user1 = innerData["_id"]["user1"].string
                            let user2 = innerData["_id"]["user2"].string
                            
                            var newUser: User
                            let user1MessagesCount = innerData["user1"].count
                            let user2MessagesCount = innerData["user2"].count
                            let minute: NSTimeInterval = 60, hour = minute * 60, day = hour * 24
                            let date = NSDate(timeIntervalSinceNow: -minute)
                            
                            for(var k = 0 ; k < user1MessagesCount; k++){
                                
                                self.allMessages.append(self.createJSQMessage(user1!, localMessage: innerData["user1"][k]))
                                if (user1 != account.user.userId){
                                	self.unreadMessageCount++
                                }
                                
                            }
                            for (var k = 0; k < user2MessagesCount; k++){
                                
                                self.allMessages.append(self.createJSQMessage(user2!, localMessage: innerData["user2"][k]))
                                if (user2 != account.user.userId){
                                    self.unreadMessageCount++
                                }
                                
                            }
                            self.reorderChat()
                            completion(result: true)
                    }
                    
            }
        
    }
    
    func createJSQMessage(user: String,localMessage: JSON)->JSQMessage{
        
        let newMessage = localMessage["message"].string
        let timestamp = localMessage["timestamp"].double!/1000
        let text = localMessage["message"].string
        let myDouble = NSNumber(double: timestamp)
        let date = NSDate(timeIntervalSince1970: Double(myDouble))
        let message = JSQMessage(senderId: user,senderDisplayName: "Sender",date: date,text: text)
        return message
        
    }
    
  
}
