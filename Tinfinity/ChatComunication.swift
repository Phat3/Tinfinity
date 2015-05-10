//
//  ChatComunication.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 12/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation

import Socket_IO_Client_Swift


class ChatComunicaction {

    //reference to the socket io client
    //At the moment we hardcode the url directly here
    private let socket = SocketIOClient(socketURL: "localhost:3000")
    
    
    /// Connect to the server through the websocket
    func connectToServer(){
        self.socket.connect()
    }

}



