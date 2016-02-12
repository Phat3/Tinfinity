//
//  ProfileViewController.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//  @author Sebastiano Mariani
//

import UIKit

class ProfileViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    
    //The user object of which we show the profile
    var user: User?
    
    //Variable used to know if the profileView is shown from the map or not
    var cameFromMap = false
    
    //Weak reference to the navigation ViewController needed for buttons action
    weak var navigationPageViewController: PageViewController?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pageViewControllerFrame: UIView!
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var disanceLabel: UILabel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let age = self.user!.age {
            self.nameAndAgeLabel.text = self.user!.name! + String(", ") + age
        } else {
            self.nameAndAgeLabel.text = self.user!.name
        }
        
        createPageViewController()
        setupPageControl()
        distance()
        buttons()
        stopLoading()
    }
    
    func loading() {
        self.activityIndicator.startAnimating()
        self.acceptButton.enabled = false
        self.declineButton.enabled = false
        self.sendRequestButton.enabled = false
    }
    
    func stopLoading() {
        self.activityIndicator.stopAnimating()
        self.acceptButton.enabled = true
        self.declineButton.enabled = true
        self.sendRequestButton.enabled = true
    }
    
    /*
     * In base alla relazione con l'utente, decidiamo quali buttons mostrare
     */
    private func buttons() {
        if(self.user!.isFriend == true || self.user!.hasSentRequest == true) {
            self.declineButton.hidden = true
            self.acceptButton.hidden = true
            self.sendRequestButton.hidden = true
        } else if(self.user!.hasSentRequest == false && self.user!.hasReceivedRequest == false) {
            self.declineButton.hidden = true
            self.acceptButton.hidden = true
        } else if(self.user!.hasReceivedRequest == true) {
            self.sendRequestButton.hidden = true
        }
    }
    
    /*
     * Calcoliamo la distanza dell'utente rispetto a noi e mostriamola
     * nella sua label
     */
    private func distance() {
        if let distance = self.user!.distance {
            if(distance >= 1000) {
                self.disanceLabel.text = "\(String(format:"%.0f", round(distance/1000))) kilometers away"
            } else {
                self.disanceLabel.text = "\(String(format:"%.0f", round(distance))) meters away"
            }
        } else {
            self.disanceLabel.text = "Location unknown"
        }
    }
    
    private func createPageViewController() {
        
        //This page view controller is the one used to slide the images
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("photoPageController") as! UIPageViewController
        pageController.dataSource = self
        
        if user?.images.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        pageViewController?.view.frame = pageViewControllerFrame.frame
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PhotoItemViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PhotoItemViewController
        
        if itemController.itemIndex+1 < user?.images.count && user?.images[itemController.itemIndex+1] != nil  {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PhotoItemViewController? {
        
        if itemIndex < user?.images.count{
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("itemController") as! PhotoItemViewController
            pageItemController.itemIndex = itemIndex
            pageItemController.image = user?.images[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        //The images array is always at fixed length 6, so we nee to cycle it and check how many images there are inside
        var i = 0
        while let _ = user?.images[i]{
            i++
        }
        return i
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    @IBAction func chatClick(){
        let newViewController = self.navigationPageViewController!.viewControllerAtIndex(2) as! UINavigationController
        
        let chatListController = newViewController.topViewController as! ChatListViewController
        
        if let _ = Chat.getChatByUserId(self.user!.userId).0{
            chatListController.newChat = false
            chatListController.clickedUserId = self.user!.userId
        }else{
            chatListController.newChat = true
            account.chats.insert(Chat(user: self.user!, lastMessageText: "", lastMessageSentDate: NSDate()), atIndex: 0)
        }
        
        self.navigationPageViewController!.setViewControllers([newViewController], direction: .Forward, animated: true,completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func sendRequestClick() {
        if let username = user!.name {
            let alert = UIAlertController(title: "Send Friend Request", message: "Do you want to add \(username)?", preferredStyle: .ActionSheet)
            
            let confirmAction = UIAlertAction(title: "Send", style: .Default, handler: handleSendRequest)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelSendRequest)
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        

    }
    
    func handleSendRequest(alertAction: UIAlertAction!) -> Void {
        loading()
        user?.sendFriendRequest({ (result) -> Void in
            // Ricarichiamo i bottoni corretti
            self.buttons()
            self.stopLoading()
        })
    }
    
    func cancelSendRequest(alertAction: UIAlertAction!) {}
    
    
    @IBAction func acceptClick() {
        loading()
        user?.acceptFriendRequest({ (result) -> Void in
            // Ricarichiamo i bottoni corretti
            self.buttons()
            self.stopLoading()
        })
        
        
    }
    
    @IBAction func declineClick() {
        loading()
        user?.declineFriendRequest({ (result) -> Void in
            // Ricarichiamo i bottoni corretti
            self.buttons()
            self.stopLoading()
        })
        
    }
    
    //Function called after the close button is clicked, which dismiss the profile view Controller and goes back to the last controller(map view controller)
    @IBAction func closeProfile(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
