//
//  ChatCustomCell.swift
//  tinFinity
//
//  Created by Alberto Fumagalli on 16/02/15.
//  Copyright (c) 2015 Alberto Fumagalli. All rights reserved.
//

import UIKit

class ChatCustomCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatAvatar: UIImageView!
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var unreadMessagesNumber: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
