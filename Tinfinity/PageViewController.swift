//
//  PageViewController.swift
//  
//
//  Created by Alberto Fumagalli on 24/09/15.
//
//

import UIKit


class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var index = 1
    var identifiers: NSArray = ["leftViewController", "mainViewController", "rightViewController"]
    
    override func viewDidLoad() {
        
        //DATA SOURCE IS NOT SETTED TO PREVENT SWIPE GESTURE ON PAGE VIEW CONTROLLER
        //self.dataSource = self
        self.delegate = self
        
        let startingViewController = self.storyboard!.instantiateViewControllerWithIdentifier("mainViewController") as! ViewController
        startingViewController.pageViewController = self
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        
        //first view controller = firstViewControllers navigation controller
        if index == 1 {
            
            let vC = self.storyboard!.instantiateViewControllerWithIdentifier("mainViewController") as! ViewController
            vC.pageViewController = self
            return vC
            
        }
        
        //second view controller = secondViewController's navigation controller
        if index == 0 {
            
           	let vC = self.storyboard!.instantiateViewControllerWithIdentifier("leftViewController") as! SettingsViewController
            vC.pageViewController = self
            return vC
        }
        
        if index == 2{
            
            let navController = self.storyboard!.instantiateViewControllerWithIdentifier("rightViewController") as! UINavigationController
            let topVC = navController.topViewController as! ChatListViewController
            topVC.pageViewController = self
            return navController
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        index = self.identifiers.indexOfObject(identifier!)
        
        //if the index is the end of the array, return nil since we dont want a view controller after the last one
        if index == identifiers.count - 1 {
            
            return nil
        }
        
        //increment the index to get the viewController after the current index
        self.index = self.index + 1
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        index = self.identifiers.indexOfObject(identifier!)
        
        //if the index is 0, return nil since we dont want a view controller before the first one
        if index == 0 {
            
            return nil
        }
        
        //decrement the index to get the viewController before the current one
        index = index - 1
        return self.viewControllerAtIndex(self.index)
        
    }
    
}