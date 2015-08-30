//
//  ChatListViewController.swift
//  tinFinity
//
//  Created by Alberto Fumagalli on 16/02/15.
//  Copyright (c) 2015 Alberto Fumagalli. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var defaultMessage: UILabel!
    
    var chats: [Chat] { return account.chats }
    var imageCache = [String:UIImage]()
    
    var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //The defualt message is hidden by default
        defaultMessage.hidden = true
        defaultMessage.text = "You have no people connected to you. Look in the map to start chatting!"
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 247/255, green: 246/255, blue: 243/255, alpha: 1)
        
        //If we have no messages in the list we hide the tableView and show the defaultMessage
        if(chats.count == 0){
            chatTableView.hidden = true
            defaultMessage.hidden = false
        }
        
        //Implement the pull to refresh
		self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: Selector("updateData"), forControlEvents: UIControlEvents.ValueChanged)
        self.chatTableView.addSubview(refreshControl)
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
        
    }
    
   func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //we need to obtain the cell to set his values
        let cell = chatTableView.dequeueReusableCellWithIdentifier("chatCell") as! ChatCustomCell
        let chat = chats[indexPath.row]
    
        // Update the cell with the avatars
        dispatch_async(dispatch_get_main_queue(), {
            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? ChatCustomCell {
                cellToUpdate.chatAvatar.image = ImageUtil.cropToSquare(image: chat.user.image!)
            }
        })
    
    	//Now we need to make the chatAvatar look round
    	var frame = cell.chatAvatar.frame
    	let imageSize = frame.size.height
    	cell.chatAvatar.frame = frame
    	cell.chatAvatar.layer.cornerRadius = imageSize / 2.0
    	cell.chatAvatar.clipsToBounds = true
    
        cell.nameLabel.text = chat.user.name
        cell.messageLabel.text = chat.lastMessageText
    	cell.unreadMessagesNumber.layer.cornerRadius = 8
    	if(chat.unreadMessageCount != 0){
        	cell.unreadMessagesNumber.hidden = false
            cell.unreadMessagesNumber.setTitle(String(chat.unreadMessageCount), forState: .Normal)
            cell.messageTime.textColor = UIColor.blueColor()
        }else{
        	cell.unreadMessagesNumber.hidden = true
            cell.messageTime.textColor = UIColor.blackColor()
    	}
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chatSelected") {
                let path = self.chatTableView.indexPathForSelectedRow()!
                let nextViewcontroller = segue.destinationViewController as! ChatViewController
                nextViewcontroller.chat = chats[path.row]
            	chats[path.row].unreadMessageCount = 0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
     
        for(var i = 0; i < chats.count; i++){
            chats[i].updateLastMessage()
        }
        chatTableView.reloadData()
    }
    
    func updateData(){
        for (var i = 0; i < chats.count; i++){
            chats[i].fetchNewMessages({ (result) -> Void in
                if (i == self.chats.count){
                    self.refreshControl.endRefreshing()
                    self.chatTableView.reloadData()
                }
            })
        }
    }

}
