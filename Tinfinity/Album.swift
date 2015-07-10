//
//  Album.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 06/07/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class Album: NSObject {
    let id: String
    let name: String
    var cover: String = ""
    
    init(id:String, name:String){
        	self.id = id
            self.name = name
    }
}
