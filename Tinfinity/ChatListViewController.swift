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
    
    
    
    var chats:Array <Chat> = [
        Chat(name:"Alberto", surname:"Fumagalli", image:"https://fbcdn-sphotos-b-a.akamaihd.net/hphotos-ak-xpa1/v/t1.0-9/10940548_10205850224402630_1175390953583471916_n.jpg?oh=c628610b24d82039e95bb70675c7d87f&oe=555E6416&__gda__=1431927296_9b78b4026548545be7872e338a2e88e0"),
        Chat(name:"Sebastiano  ",surname: "Mariani", image:"https://myapnea.org/assets/default-user-cbd45c51fcd2805b037bc985438f7b6d.jpg"),
        Chat(name:"Riccardo", surname:"Mastellone", image:"https://pbs.twimg.com/profile_images/1725683917/340366_10150967276105109_758290108_21632905_1767193586_o.jpg"),
       
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.chatTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.chatTableView.dataSource = self
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //we need to obtain the cell to set his values
        let cell: ChatCustomCell = chatTableView.dequeueReusableCellWithIdentifier("chatCell") as! ChatCustomCell
        let chat = chats[indexPath.row]
        cell.nameLabel.text = chat.name + " " + chat.surname
        cell.messageLabel.text = chat.outMessages[0]
        cell.chatAvatar.image = chat.image
        
        //Now we need to make the chatAvatar look round
        var frame = cell.chatAvatar.frame
        let imageSize = 55 as CGFloat
        frame.size.height = imageSize
        frame.size.width  = imageSize
        cell.chatAvatar.frame = frame
        cell.chatAvatar.layer.cornerRadius = imageSize / 2.0
        cell.chatAvatar.clipsToBounds = true
        
        return cell
    }

}
