//
//  Crypto.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import Foundation

class Crypto{
    
    
    //trucco per poter avere variabili di classe
    //non sono ancora state implementate in swift
    //
    //struct che definisce le label poer riprendere le chiavi create dal keychain
    private struct KeychainLabel{
        
        static var publicKey : String = "com.tinfinity.crypto.publickey"
        
        static var privateKey : String = "com.tinfinity.crypto.privatekey"

    }
    
    //opzioni per la chiave pubblica
    //la vogliamo permanente e con la label specificata
    let publicKeyParameters: [String: AnyObject] = [kSecAttrIsPermanent: true, kSecAttrApplicationTag: KeychainLabel.publicKey]
    
    //opzioni per la chiave privata
    //la vogliamo permanente e con la label specificata
    let privateKeyParameters: [String: AnyObject] = [ kSecAttrIsPermanent: true, kSecAttrApplicationTag: KeychainLabel.privateKey]
    
    //referenza alla chiave pubblica vera e propria
    var publicKey : SecKeyRef?
    
    //referenza alla chiave private vera e propria
    var privateKey : SecKeyRef?
    
    init(){
        
        //controlliamo se abbiamo la chiave gia salvata nel keychain
        self.privateKey = self.findKey(KeychainLabel.privateKey)
        self.publicKey = self.findKey(KeychainLabel.publicKey)
        
        //se non esistono (prima volta che si attiva l applicazione) la generiamo
        if ( (self.privateKey == nil) || (self.publicKey == nil)){
            
            //definiamo i parametri generali
            let parameters: [String: AnyObject] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeySizeInBits: 2048,
                kSecPublicKeyAttrs.takeUnretainedValue() as String: publicKeyParameters,
                kSecPrivateKeyAttrs.takeUnretainedValue() as String: privateKeyParameters
            ]
            
            var publicKeyPtr, privateKeyPtr: Unmanaged<SecKey>?
            
            //generiamo
            SecKeyGeneratePair(parameters, &publicKeyPtr, &privateKeyPtr)
            
            //settiamo le referenze
            self.privateKey = privateKeyPtr!.takeRetainedValue()
            self.publicKey = publicKeyPtr!.takeRetainedValue()
            
        }

    }
    
    //ritorna il vaolore della chive se presente nel keychain altrimenti ritorna nil
    private func findKey(tag: String) -> SecKey? {
        
        //parametri di ricerca
        let query: [String: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag: tag,
            kSecReturnRef: true
        ]
        
        var keyPtr: Unmanaged<AnyObject>?
        let result = SecItemCopyMatching(query, &keyPtr)
        
        //controlliamo l esito
        switch result {
            case noErr:
                let key = keyPtr!.takeRetainedValue() as SecKey
                return key
            case errSecItemNotFound:
                return nil
            default:
                println("Error occurred: \(result)`")
                return nil
        }
    }
    
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