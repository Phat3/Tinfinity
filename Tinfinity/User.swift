//
//  UserProfile.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//
import Foundation.NSString
import UIKit

class User {
    var firstName: String
    var lastName: String
    var email: String?
    var imageUrl : String?
    var token: String?
    var name: String? {
        return firstName + " " + lastName
    }
    var initials: String? {
        var initials: String?
        for name in [firstName, lastName] {
            var initial = name.substringToIndex(advance(name.startIndex, 1))
            if initial.lengthOfBytesUsingEncoding(NSNEXTSTEPStringEncoding) > 0 {
                initials = (initials == nil ? initial : initials! + initial)
            }
        }
        return initials
    }
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }

}

