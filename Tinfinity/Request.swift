//
//  Request.swift
//  Tinfinity
//
//  @author Riccardo Mastellone <riccardo.mastellone@gmail.com>
//

import Foundation

class Request: NSObject {
    let user_id: String
    let user: User
    
    init(user_id:String){
        self.user_id = user_id
        self.user = User(userId: user_id)
    }
    
    init(user_id: String, user: User) {
        self.user_id = user_id
        self.user = user
    }
}
