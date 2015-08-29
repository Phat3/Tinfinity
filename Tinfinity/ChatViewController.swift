//
//  ChatViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 24/05/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Socket_IO_Client_Swift
import SwiftyJSON

class ChatViewController: JSQMessagesViewController {

    var chat: Chat?
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var incomingAvatar: JSQMessagesAvatarImage?
    
    var outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(ImageUtil.cropToSquare(image: account.pictures[0]!), diameter: 30)

    
    // Socket IO client
    private let socket = SocketIOClient(socketURL: NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        
        senderId = account.user.userId
        senderDisplayName = "Me"
        
        self.connectToServer()
        self.addHandler()
        
        // We need it here as 'chat' before does not exist
        incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(ImageUtil.cropToSquare(image: chat!.user.image!), diameter: 30)
        
        // We don't need the button on the left
        self.inputToolbar.contentView.leftBarButtonItem = nil;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Metodi necessari per JSQMessagesViewController
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        var data = self.chat!.allMessages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var data = self.chat!.allMessages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        var data = self.chat!.allMessages[indexPath.row];
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
        
        var newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text);
        chat!.allMessages.append(newMessage)
        
        var json = [
            "user1" : account.user.userId,
            "user2" : chat!.user.userId,
            "token" : account.token,
            "message" : text
        ]
        self.socket.emit("message", json)
        
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
    
    // Connect to the server through the websocket
    func connectToServer(){
        self.socket.connect()
    }
    
    // Handle websocket event
    func addHandler() {
        socket.on("message-" + account.user.userId) {data, ack in
            let json = JSON(data!)
            let newMessage = JSQMessage(senderId: self.chat!.user.userId, displayName: self.chat!.user.firstName, text: json[0]["message"].string);
            self.chat!.allMessages.append(newMessage)
            self.finishReceivingMessage();
        }
        
        
    }

}
