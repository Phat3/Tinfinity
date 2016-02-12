//
//  UserAnnotation.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//

import MapKit
import UIKit

class UserAnnotation: NSObject, MKAnnotation {
    var user: User
    var coordinate: CLLocationCoordinate2D{
        return user.position!
    }
    var title: String?{
        return user.name!
    }
    
    var image: UIImage{
        return user.image!
    }
    
    var subtitle: String?{
        return "View profile"
    }
    
    init(user: User) {
        self.user = user
    }
}