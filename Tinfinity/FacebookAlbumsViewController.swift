//
//  FacebookAlbumsViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 01/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit


class FacebookAlbumsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,FacebookAPIControllerProtocol {
	
    @IBOutlet weak var activityIndicator: UITableView!
	@IBOutlet var albumTabelView: UITableView!
    let facebookApi = FacebookAPIController()
    var albums = [Album]()
    var imageCache = [String: UIImage]()
    var albumId  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Let's set the colors for the navigation bar, text and button
        let red = CGFloat(0.0/255.0)
        let blue = CGFloat(204.0/255.0)
        let green = CGFloat(102.0/255.0)
        let alpha = CGFloat(0.3)
        navigationController!.navigationBar.barTintColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        albumTabelView.hidden = true
        facebookApi.delegate = self
        facebookApi.fetchAlbums()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return albums.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumCell", forIndexPath: indexPath) as! AlbumCustomCell

        // Configure the cell...
        let album = albums[indexPath.row]
		cell.albumName.text = album.name
        let url = album.cover
        /*let url = NSURL(string: album.cover)
        let data = NSData(contentsOfURL: url!)
        cell.imageView!.image = UIImage(data: data!)!
        //println("Nome album: " + album.name + "\nCover link: " + album.cover)
        return cell*/
        
        //IMPLEMENTAZIONE CON CARICAMENTO ASINCRONO, PIU PERFORMANTE MA IMMAGINI CARICATE IN ORDINE SPARSO
        if (!url.isEmpty){
            // Immagine già recuperata, usiamola
            if let img = imageCache[url] {
                cell.albumPicture!.image = img
            } else {
                let request: NSURLRequest = NSURLRequest(URL: NSURL(string: url)!)
                let mainQueue = NSOperationQueue.mainQueue()
                NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: {     (response, data, error) -> Void in
                    if error == nil {
                        // Convert the downloaded data in to a UIImage object
                        let image = UIImage(data: data!)
                        //Store in our cache the image
                        self.imageCache[url] = image
                        // Update the cell
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as! AlbumCustomCell? {
                                cellToUpdate.albumPicture!.image = ImageUtil.cropToSquare(image: image!)
                                tableView.reloadData()
                            }
                        })
                    }
                    else {
                        print("Error: \(error!.localizedDescription)", terminator: "")
                    }
                })
            }
        }
       
        return cell

    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let path = self.albumTabelView.indexPathForSelectedRow!
        albumId = albums[path.row].id
        let photoViewController = segue.destinationViewController as! FacebookPhotoCollectionViewController
        photoViewController.albumId = self.albumId
        photoViewController.albumName = albums[path.row].name
    }
    
    func didReceiveFacebookAPIResults(results: [Album]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.hidden = true
            self.albumTabelView.hidden = false
            self.albums = results
            self.albumTabelView!.reloadData()
        })
    }
    
    
}
