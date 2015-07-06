//
//  Album.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 06/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class Album: NSObject {
    let name: String
    let link: String
    let cover: String
    
        init(name:String, link:String, cover:String){
            self.name = name
            self.link = link
            self.cover = cover
    }
}
