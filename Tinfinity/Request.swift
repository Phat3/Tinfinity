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
    
    static func getRequestByUserId(user_id: String) -> (Request?, Int?){
        for(var i=0; i < account.requests.count; i++){
            if (account.requests[i].user.userId == user_id){
                return (account.requests[i],i)
            }
        }
        return (nil,nil)
    }
}
