//
//  Crypto.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//
//  Classe per gestire tutte le funzioni crittografiche dell applicazione

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
    private let publicKeyParameters: [String: AnyObject] = [kSecAttrIsPermanent: true, kSecAttrApplicationTag: KeychainLabel.publicKey]
    
    //opzioni per la chiave privata
    //la vogliamo permanente e con la label specificata
    private let privateKeyParameters: [String: AnyObject] = [ kSecAttrIsPermanent: true, kSecAttrApplicationTag: KeychainLabel.privateKey]
    
    //referenza alla chiave pubblica vera e propria
    private var publicKey : SecKeyRef?
    
    //referenza alla chiave private vera e propria
    private var privateKey : SecKeyRef?
    
    private var blockSize : UInt?
    
    //costruttore che controlla se esistono gia le chiavi nel keychain
    //se non esistyono le crea
    init(){
        
        //controlliamo se abbiamo la chiave gia salvata nel keychain
        self.privateKey = self.findKey(KeychainLabel.privateKey)
        self.publicKey = self.findKey(KeychainLabel.publicKey)
        
        //se non esistono (prima volta che si attiva l applicazione) la generiamo
        if ( (self.privateKey == nil) || (self.publicKey == nil)){
            println("entrato")
            self.generateRSAKeys()
            
        }
        
        self.blockSize = SecKeyGetBlockSize(publicKey)

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
    
    //genera la coppia di chiavi pubbliche e private RSA
    private func generateRSAKeys(){
        
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
    
    //cripta il messaggio usando RSA
    func RSAEncrypt(message : String) -> [UInt8]{
        //step1 : convertire il plaintext in utf8
        let plainTextData = [UInt8](message.utf8)
        //step2 : ricavare la lunghezza del testo in utf8
        let plainTextDataLength = UInt(plainTextData.count)
        //step3 : creare il buffer per il testo criptato
        var encryptedData = [UInt8](count: Int(self.blockSize!), repeatedValue: 0)
        //step4 : criptare
        SecKeyEncrypt(publicKey, SecPadding(kSecPaddingPKCS1),  plainTextData, plainTextDataLength, &encryptedData, &self.blockSize!)
        //ritorniamo il cipher
        return encryptedData
        
    }
    
    //decripta il messaggio usando RSA
    func RSADecrypt(encryptedData : [UInt8]) -> String{
        //step1 : creare il buffer per i dati decriptati
        var decryptedData = [UInt8](count: Int(self.blockSize!), repeatedValue: 0)

        //decriptare
        SecKeyDecrypt(privateKey, SecPadding(kSecPaddingPKCS1),encryptedData, self.blockSize!, &decryptedData, &self.blockSize!)
        
        let decryptedText = String(bytes: decryptedData, encoding:NSUTF8StringEncoding)
        //ritorniamo il plain
        return decryptedText!
    }
    

}