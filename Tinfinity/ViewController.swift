//
//  ViewController.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //DEBUG
        
        var testo = "ciao come va?"
        
        println("Testo in chiaro : \(testo)")
        
        var cryptoAPI = Crypto()
        
        var cipher: [UInt8] = cryptoAPI.RSAEncrypt(testo)
        
        var plain: String = cryptoAPI.RSADecrypt(cipher)
        
        println("Testo decriptato : \(plain)")
        println(cipher)
        var array = [180, 146, 234, 12, 248, 219, 150, 62, 33, 249, 95, 30, 240, 211, 200, 244, 102, 111, 77, 186, 209, 123, 254, 70, 224, 88, 58, 136, 207, 189, 19, 11, 188, 123, 44, 43, 30, 85, 72, 252, 77, 8, 34, 130, 249, 235, 31, 223, 66, 120, 20, 172, 71, 224, 170, 213, 93, 172, 158, 193, 84, 217, 45, 212, 120, 53, 151, 250, 235, 104, 123, 179, 175, 176, 6, 169, 161, 153, 198, 28, 228, 251, 209, 21, 100, 7, 207, 0, 99, 213, 58, 249, 73, 169, 210, 17, 161, 20, 194, 6, 164, 93, 196, 201, 230, 125, 254, 152, 109, 1, 74, 91, 254, 230, 92, 42, 127, 45, 112, 185, 99, 153, 95, 59, 78, 135, 147, 54, 22, 72, 29, 156, 15, 81, 234, 27, 234, 39, 134, 235, 125, 28, 124, 164, 81, 126, 177, 99, 100, 157, 42, 41, 81, 28, 13, 95, 234, 212, 168, 229, 215, 199, 232, 15, 95, 18, 160, 148, 58, 83, 141, 161, 124, 144, 226, 177, 179, 224, 12, 176, 3, 25, 21, 4, 107, 137, 15, 25, 52, 253, 23, 35, 111, 214, 81, 44, 31, 173, 73, 155, 193, 253, 189, 97, 178, 88, 1, 106, 73, 108, 242, 35, 85, 38, 152, 67, 212, 133, 157, 117, 80, 200, 22, 126, 176, 145, 29, 239, 160, 87, 150, 168, 71, 70, 201, 164, 157, 178, 44, 133, 219, 46, 206, 135, 168, 156, 199, 81, 196, 60, 77, 30, 125, 211, 169, 78]
        
        
        Alamofire.request(.POST, "http://local.tinfinity.com/prova", parameters: ["foo": array ])
            .responseString { (_, _, string, _) in
                println(string!)
            }
            .responseJSON { (_, _, JSON, _) in
                println(JSON!)
            }
 

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

