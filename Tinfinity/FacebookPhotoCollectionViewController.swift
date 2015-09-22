//
//  FacebookPhotoCollectionViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 16/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

let reuseIdentifier = "photoCell"

class FacebookPhotoCollectionViewController: UICollectionViewController, FacebookAPIControllerPhotoProtocol {
	
    //Costante utilizzata per settare i margini di ogni elemento rispetto agli altri
    private let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    @IBOutlet var photoCollection: UICollectionView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    let facebookApi = FacebookAPIController()
    var albumId: String = ""
    var albumName: String = ""
    var pictures = [IdAndImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = albumName
        
        facebookApi.photoDelegate = self
        facebookApi.fetchPreviewPhoto(albumId)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return pictures.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PictureCollectionViewCell
        cell.picture.contentMode = UIViewContentMode.ScaleAspectFit
        cell.picture.image = pictures[indexPath.row].image
    
        return cell
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    func didReceiveFacebookPhoto(results: [IdAndImage]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activitySpinner.hidden = true
            self.pictures = results
            self.photoCollection.reloadData()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        //let cell = sender as! PictureCollectionViewCell
        let indexPaths : NSArray = self.photoCollection.indexPathsForSelectedItems()!
        let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
        let pictureViewController = segue.destinationViewController as! PictureDetailViewController
        pictureViewController.imageId = pictures[indexPath.row].id
    }
}

	extension FacebookPhotoCollectionViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            //let picture =  pictures[indexPath.row]
            return CGSize(width: 60, height: 60)
    }
    
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            //imposta i margini settati nella costante sectionInsets
            return sectionInsets
    }
        
   }
