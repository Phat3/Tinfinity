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
}
