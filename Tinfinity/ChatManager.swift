//
//  ChatComunication.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 12/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation

import Socket_IO_Client_Swift


class ChatManager{

    //reference to the socket io client
    //At the moment we hardcode the url directly here
    private let socket = SocketIOClient(socketURL: "localhost:3000", opts : ["log" : true])
    
    init(){
        //init the handlers
        self.addHandlers()
    }
    
    /// Connect to the server through the websocket
    func connectToServer(){
        self.socket.connect()
    }
    
    /// Send a chat message to the server
    func sendMessage(){
        //TODO integrate crypto functionality before sending the message
        self.socket.emit("message", "messaggio da swift")
    }
    
    func addHandlers() {
        // Our socket handlers go here
        
        //handkers of chat server reply
        self.socket.on("reply") {[weak self] data, ack in
            println(data)
            return
        }
    }

}



