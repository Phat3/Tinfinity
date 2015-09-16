//
//  AlbumCustomCell.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 16/09/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class AlbumCustomCell: UITableViewCell {
    
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumPicture: UIImageView!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
