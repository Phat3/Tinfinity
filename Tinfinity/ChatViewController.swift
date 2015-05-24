//
//  ChatViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 24/05/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var chat: Chat?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        
        senderId = account.user.userId
        senderDisplayName = "Me"
        
        //Sample chat
        chat!.loadedMessages = [
                JSQMessage(senderId: account.user.userId, senderDisplayName: account.user.name, date: NSDate(timeIntervalSinceNow: -60*60*24*2-60*60), text: "I really enjoyed programming with you! :-)"),
            JSQMessage(senderId: "2", senderDisplayName:"Ciccio", date: NSDate(timeIntervalSinceNow: -60*60*24*2-60*60), text: "So did I!")
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Metodi necessari per JSQMessagesViewController
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        var data = self.chat!.loadedMessages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var data = self.chat!.loadedMessages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chat!.loadedMessages.count
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text);
        chat!.loadedMessages += [newMessage]
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }

}
