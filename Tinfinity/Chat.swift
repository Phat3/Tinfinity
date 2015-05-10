//
//  Chat.swift
//  tinFinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//

import Foundation
import UIKit

class Chat {
    
    var name : String
    var surname: String
    var imageUrl : String?
    var image : UIImage?
    var incMessages = [
        String("hey"),
        String("what's up?")
    ]
    
    var outMessages = [
        String("yo"),
        String("Nothing mutch")
    ]
    
    init(name:String, surname:String, image:String?){
        self.name = name
        self.surname = surname
        self.imageUrl = image
    }
    
}
