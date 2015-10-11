//
//  ProfileViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 11/10/15.
//  Copyright © 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    
    //The user object of which we show the profile
    var user: User?
    
    //Weak reference to the navigation ViewController needed for buttons action
    weak var navigationPageViewController: PageViewController?
    
    @IBOutlet weak var pageViewControllerFrame: UIView!
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameAndAgeLabel.text = self.user!.name
        createPageViewController()
        setupPageControl()
    }
    
    private func createPageViewController() {
        
        //This page view controller is the one used to slide the images
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("photoPageController") as! UIPageViewController
        pageController.dataSource = self
        
        if user?.images.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as! [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
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
        
        if itemController.itemIndex+1 < user?.images.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PhotoItemViewController? {
        
        if itemIndex < user?.images.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("itemController") as! PhotoItemViewController
            pageItemController.itemIndex = itemIndex
            pageItemController.image = user?.images[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return (user?.images.count)!
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

}
