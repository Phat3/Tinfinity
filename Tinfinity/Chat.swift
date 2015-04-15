//
//  Chat.swift
//  tinFinity
//
//  Created by Alberto Fumagalli on 16/02/15.
//  Copyright (c) 2015 Alberto Fumagalli. All rights reserved.
//

import Foundation
import UIKit

class Chat {
    
    var name : String
    var surname: String
    var avatar : String
    var incMessages = [
        String("hey"),
        String("what's up?")
    ]
    
    var outMessages = [
        String("yo"),
        String("Nothing mutch")
    ]
    
    init(name:String, surname:String, avatar:String){
        self.name = name
        self.surname = surname
        self.avatar = avatar
    }
    
}
