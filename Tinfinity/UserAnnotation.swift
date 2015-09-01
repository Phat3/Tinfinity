//
//  UserAnnotation.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 30/08/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import MapKit
import UIKit

class UserAnnotation: NSObject, MKAnnotation {
    var user: User
    var coordinate: CLLocationCoordinate2D{
        return user.position!
    }
    
    init(user: User) {
        self.user = user
    }
}