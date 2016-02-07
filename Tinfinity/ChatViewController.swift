//
//  ChatViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 24/05/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SocketIOClientSwift
import SwiftyJSON

class ChatViewController: JSQMessagesViewController {

    var chat: Chat?
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0))
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var incomingAvatar: JSQMessagesAvatarImage?
    
    var outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(ImageUtil.cropToSquare(image: account.user.image!), diameter: 30)
    
    var isConnected = false
    var registerdHandlers = false
    
    //Weak reference to parent pageViewController needed by profileViewController, and we need to assign it
    weak var pageViewController: PageViewController?

    // Socket IO client
    private let socket = SocketIOClient(socketURL: NSURL(string:NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Until Websockets are connected, we have to prevent messages being sent
        toggleSend()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        
        senderId = account.user.userId
        senderDisplayName = chat?.user.name
        
        self.connectToServer()
        self.addHandler()
        
        if let name = chat!.user.name {
            self.title = name
        }
                
        // We need it here as 'chat' before does not exist
        incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(ImageUtil.cropToSquare(image: chat!.user.image!), diameter: 30)
        
        // We don't need the button on the left
        self.inputToolbar!.contentView!.leftBarButtonItem = nil;
        
        //We want to show last messages
        self.scrollToBottomAnimated(false)
        
        //Hotfix for JSQCollectionView chat width's bug
        collectionView?.reloadData()
        
    }
    
    /*
     * Enables and disables send button
     */
    func toggleSend() {
        self.inputToolbar!.contentView!.textView!.editable = self.isConnected
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.chat!.allMessages.count == 0{
            account.chats.removeFirst()
        }
        
        self.chat?.unreadMessageCount = 0
        self.chat?.resetCoreUnreadCounter()
    }
    
    //If the app became active n this view, we need to execute a finishReceiving message in the case there are new messages to display
    override func viewWillAppear(animated: Bool) {
        
        if(chat?.unreadMessageCount != 0) {
            self.finishReceivingMessage()
        }
    }
    
    //Metodi necessari per JSQMessagesViewController
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.chat!.allMessages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = self.chat!.allMessages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if self.shouldShowTimestampForIndexPath(indexPath.row) {
            return CGFloat(20)
        }
        return CGFloat(2)
        
    }
    
    let timestampFormatter = JSQMessagesTimestampFormatter()
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.chat?.allMessages[indexPath.item]
        if self.shouldShowTimestampForIndexPath(indexPath.row) {
            return self.timestampFormatter.attributedTimestampForDate(message?.date)
        }
        return nil
    }
    
    func shouldShowTimestampForIndexPath(indexPath: Int) -> Bool{
        if(indexPath != 0){
            if(NSCalendar.currentCalendar().compareDate((chat?.allMessages[indexPath-1].date)!, toDate: (chat?.allMessages[indexPath].date)!, toUnitGranularity: .Minute) == NSComparisonResult.OrderedAscending ){
                return true
            }else{
                return false
            }
        }else{
            return true
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let data = self.chat!.allMessages[indexPath.row];
        if (data.senderId == self.senderId) {
            return self.outgoingAvatar
        } else {
            return self.incomingAvatar
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chat!.allMessages.count
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if (self.chat?.allMessages.count == 0){
            account.chats[0].saveNewChat()
        }
        
        let newMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text);
        chat!.allMessages.append(newMessage)
        
        let json = [
            "user1" : account.user.userId,
            "user2" : chat!.user.userId,
            "token" : account.token,
            "message" : text
        ]
        self.socket.emit("message", json)
        chat!.updateLastMessage()
        
        //Let's save it in core data
        chat!.saveNewMessage(newMessage, userId: chat!.user.userId)
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
    
    // Connect to the server through the websocket
    func connectToServer(){
        // Avoid multiple connections
        if(!self.isConnected) {
            self.socket.connect()
        }
    }
    
    // Handle websocket event
    func addHandler() {
        socket.on("message-" + account.user.userId) {[weak self] data, ack in
            
            let json = JSON(data)
            print(data)
            let user_id = json[0]["user_id"].string
            
            // Message received for this conversation
            if(self!.chat!.user.userId == user_id) {
                self!.finishReceivingMessage()
            }
            
        }
        
        socket.on("connect") {[weak self] data, ack in
            self!.isConnected = true;
            self!.toggleSend()
        }
        
        socket.on("disconnect") {[weak self] data, ack in
            self!.isConnected = false;
            self!.toggleSend()
            self!.connectToServer()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "viewProfile"){
            let profileController = segue.destinationViewController as! ProfileViewController
            profileController.user = self.chat?.user
            profileController.navigationPageViewController = self.pageViewController
        }
    }
    

}
