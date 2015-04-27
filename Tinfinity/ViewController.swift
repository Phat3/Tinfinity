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
    
    var chat = ChatManager()
    
    @IBOutlet weak var prova: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //DEBUG
        
        println("sdasd")
        
        var http = HttpReqWraper()
        
        //http.post("http://localhost:3000/auth/register-step1", params: ["foo" : "bar"])
        
        var cry = Crypto()
        
        cry.send()
    
        
        //self.chat.connectToServer()

        /*
        var testo = "ciao come va?"
        
        println("Testo in chiaro : \(testo)")
        
        var cryptoAPI = Crypto()
        
        var cipher: String = cryptoAPI.RSAEncrypt(testo)

        //decrypt del cipher
        var plain: String = cryptoAPI.RSADecrypt(cipher)
        
        println("Testo decriptato : \(plain)")
        */
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendmess(sender: AnyObject) {
       println("premuto")
       self.chat.sendMessage()
        
    }

}

