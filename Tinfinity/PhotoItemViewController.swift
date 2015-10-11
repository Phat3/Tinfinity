//
//  PhotoItemViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 11/10/15.
//  Copyright © 2015 Sebastiano Mariani. All rights reserved.
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
