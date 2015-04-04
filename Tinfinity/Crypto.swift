//
//  Crypto.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation

class Crypto{
    
    var publicKey : SecKeyRef?
    
    var privateKey : SecKeyRef?


    func generateRSAKeys(){
        
        var publicKeyPtr:  Unmanaged<SecKey>?
        var privateKeyPtr: Unmanaged<SecKey>?
        
        let parameters = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecAttrKeySizeInBits): 2048
        ]
        
    }
    
    func RSAEncrypt(message : String) -> String{
        return "ci"
    }
    
    func RSADecrypt(message : String) -> String{
     return "ci"
    }
    

}