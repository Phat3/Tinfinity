//
//  ChatComunication.swift
//  Tinfinity
//
//  @author Riccardo Mastellone
//  @author Sebastiano Mariani
//

import Foundation

import Socket_IO_Client_Swift

class ChatManager {

    // Socket IO client
    private let socket = SocketIOClient(socketURL: NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String)
    
    
    /// Connect to the server through the websocket
    func connectToServer(){
        self.socket.connect()
    }

    func sendMessage(user_id: String, message: String) {
        
        var json = [
            "user1" : account.user.userId,
            "user2" : user_id,
            "token" : account.token,
            "message" : message
        ]
        self.socket.emit("message", json)
    }
    
    func addHandlers() {
        // Debug
        self.socket.onAny {println("Got event: \($0.event), with items: \($0.items)")}
        
        socket.on("message-" + account.user.userId) {data, ack in
            println(data)
        }

        
    }

}



