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
    //private let socket = SocketIOClient(socketURL: "localhost:3000", opts : ["log" : true])
    private let socket = SocketIOClient(socketURL: "localhost:3000")
    
    private let cryptoAPI = Crypto()
    
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
        //encrypt the message
        //at the moment we use the RSA to encrypt the message itself
        //later we will use the RSA only to encrypt the shared key (simmetric). This shared key will be used to encrypt themessage
        var cipher : String = self.cryptoAPI.RSAEncrypt("messaggio da swift")
        
        var json = ["message" : cipher]
        //send the message
        self.socket.emit("message", json)
    }
    
    // Our socket handlers go here
    func addHandlers() {
        
        //handkers of chat server reply
        self.socket.on("reply") {[weak self] data, ack in

            let cipher = data![0]["message"] as! String
            
            var plain = self?.cryptoAPI.RSADecrypt(cipher)
            
            println("TESTO RICEVUTO DECRYPT: \(plain!)")
            return
        }
    }

}



