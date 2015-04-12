//
//  ViewController.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import Alamofire
import Socket_IO_Client_Swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //DEBUG
        
        let socket = SocketIOClient(socketURL: "localhost:3000")
        
        socket.connect()
        
        /*
        var testo = "ciao come va?"
        
        println("Testo in chiaro : \(testo)")
        
        var cryptoAPI = Crypto()
        
        var cipher: [UInt8] = cryptoAPI.RSAEncrypt(testo)
        

        //creiamo un oggetto data con i byte del chipher e encodiamolo in base64 cosi da poter essere mandato come stringa
        var base64 = NSData(bytes: cipher, length: cipher.count).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        //creaimo un oggetto data partendo da una stringa encodata in base64 (ricaviamo i byte del cipher originale)
        let base64dec = NSData(base64EncodedString: base64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
        //prepariamo il buffer da riempire
        var buffer = [UInt8]()
        //referenza ai byte del cipher
        let bytes = UnsafePointer<UInt8>(base64dec.bytes)
        //riempiamo il buffer
        for i in 0 ..< base64dec.length
        {
            buffer.append(bytes[i])
        }
        println(buffer)

        //decrypt del cipher
        var plain: String = cryptoAPI.RSADecrypt(buffer)
        
        println("Testo decriptato : \(plain)")
        */
        
        /*

        Alamofire.request(.POST, "http://local.tinfinity.com/prova", parameters: ["foo": base64])
            .responseString { (_, _, string, _) in
                println(string!)
            }
            .responseJSON { (_, _, JSON, _) in
                println(JSON!)
            }

        */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

