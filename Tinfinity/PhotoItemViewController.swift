//
//  PhotoItemViewController.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//

import UIKit

class PhotoItemViewController: UIViewController {

    // MARK: - Variables
    var itemIndex: Int = 0
    var image: UIImage?
    @IBOutlet var contentImageView: UIImageView?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImageView!.image = image
    }
}
