//
//  RequestListViewController.swift
//  Tinfinity
//
//  Created by Riccardo Mastellone on 19/10/15.
//  Copyright © 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation


class RequestListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    weak var pageViewController: PageViewController?
    var index: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.requests.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    //Life cycle
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //we need to obtain the cell to set his values
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell", forIndexPath: indexPath) as! RequestCustomCell
        
        let request = account.requests[indexPath.row]
        
        // Update the cell with the avatars
        dispatch_async(dispatch_get_main_queue(), {
            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? RequestCustomCell {
                cellToUpdate.avatar.image = ImageUtil.cropToSquare(image: request.user.image!)
            }
        })
        
        //Now we need to make the chatAvatar look round
        let frame = cell.avatar.frame
        let imageSize = frame.size.height
        cell.avatar.frame = frame
        cell.avatar.layer.cornerRadius = imageSize / 2.0
        cell.avatar.clipsToBounds = true
        
        cell.nameLabel.text = request.user.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        index = indexPath.row
        
        let alert = UIAlertController(title: account.requests[index].user.name, message: "", preferredStyle: .ActionSheet)
        let acceptAction = UIAlertAction(title: "Accept", style: .Default, handler: handleAccept)
        let declineAction = UIAlertAction(title: "Decline", style: .Default, handler: handleDecline)
        let profileAction = UIAlertAction(title: "View Profile", style: .Default, handler: handleProfile)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelSendRequest)
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        alert.addAction(profileAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loading() {}
    func stopLoading() {}
    
    func handleAccept(alertAction: UIAlertAction!) -> Void {
        loading()
        account.requests[index].user.acceptFriendRequest({ (result) -> Void in
            self.stopLoading()
            self.index = -1
        })
    }
    
    func handleDecline(alertAction: UIAlertAction!) -> Void {
        loading()
        account.requests[index].user.declineFriendRequest({ (result) -> Void in
            self.stopLoading()
            self.index = -1
        })
    }
    
    func handleProfile(alertAction: UIAlertAction!) -> Void {
        self.performSegueWithIdentifier("viewProfile", sender: self)
    }
    
    func cancelSendRequest(alertAction: UIAlertAction!) {
        index = -1
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "viewProfile"){
            let profileController = segue.destinationViewController as! ProfileViewController
            profileController.user = account.requests[index].user
            profileController.navigationPageViewController = self.pageViewController
        }
    }
    
    
}