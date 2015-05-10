//
//  UserProfile.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//

import Foundation
import UIKit

class UserProfile{
    
    var firstName: String
    var lastName: String
    var email: String?
    var image : UIImage?
    var token: String?
    
    init(name: String,surname :String){
        firstName = name
        lastName = surname
    }
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
    
    
}
