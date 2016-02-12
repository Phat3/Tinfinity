//
//  ViewController.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
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
