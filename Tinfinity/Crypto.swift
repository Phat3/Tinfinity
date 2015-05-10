//
//  Crypto.swift
//  Tinfinity
//
//  Created by Sebastiano Mariani on 04/04/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//
import Foundation

///  Class that manages all the cryptographic functionalities of the application
class Crypto{
    
    
    //Workaround to implement class static attributes
    //(they are not implemented yet in Swift)
    //
    //This struct defines the keychain IDs of the keys
    private struct KeychainLabel{
        
        static var publicKey : String = "com.tinfinity.crypto.publickey"
        
        static var privateKey : String = "com.tinfinity.crypto.privatekey"
        
    }
    
    //option for the public key
    //we want that the key is permanently stored in our keychain with the specified ID
    private let publicKeyParameters: [String : AnyObject] = [kSecAttrIsPermanent as! String : true as Bool, kSecAttrApplicationTag as! String : KeychainLabel.publicKey]
    
    //option for the public key
    //we want that the key is permanently stored in our keychain with the specified ID
    private let privateKeyParameters: [String: AnyObject] = [ kSecAttrIsPermanent as! String : true as Bool, kSecAttrApplicationTag as! String : KeychainLabel.privateKey]
    
    //reference to the public key
    var publicKey : SecKeyRef?
    
    //reference to the private key
    private var privateKey : SecKeyRef?
    
    private var blockSize : Int = 0
    
    /// Class constructor that checks if the keys are already present i our keychain
    /// If not the kets are created
    init(){
        
        //check if we have already the keys
        self.privateKey = findKey(KeychainLabel.privateKey)
        self.publicKey = findKey(KeychainLabel.publicKey)
        
        //If not create
        if ( (privateKey == nil) || (publicKey == nil)){
            self.generateRSAKeys()
        }
        //get the blocksize respect to the key size
        self.blockSize = SecKeyGetBlockSize(publicKey)
    }
    
    /// Returns the value of the key if its present
    /// If not it returns nil
    private func findKey(tag: String) -> SecKey? {
        
        //query paramenters
        let query: [String: AnyObject] = [
            kSecClass as! String : kSecClassKey as! String,
            kSecAttrKeyType as! String : kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as! String: tag,
            kSecReturnRef as! String : true as Bool
        ]
        
        var keyPtr: Unmanaged<AnyObject>?
        let result = SecItemCopyMatching(query, &keyPtr)
        
        /// check the query result
        switch result {
        case noErr:
            let key = keyPtr!.takeRetainedValue() as! SecKey
            return key
        case errSecItemNotFound:
            return nil
        default:
            println("Error occurred: \(result)`")
            return nil
        }
    }
    
    
    /*------------------------ RSA ------------------------*/
    
    /// Generates the RSA key pair
    private func generateRSAKeys(){
        
        //definiamo i parametri generali
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as! String : kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as! String : 2048 as Int,
            (kSecPublicKeyAttrs.takeUnretainedValue() as! String) as String: publicKeyParameters,
            (kSecPrivateKeyAttrs.takeUnretainedValue() as! String) as String: privateKeyParameters
        ]
        
        var publicKeyPtr, privateKeyPtr: Unmanaged<SecKey>?
        
        //let s generate
        SecKeyGeneratePair(parameters, &publicKeyPtr, &privateKeyPtr)
        
        //set the reference
        self.privateKey = privateKeyPtr!.takeRetainedValue()
        self.publicKey = publicKeyPtr!.takeRetainedValue()
        
    }
    
    /// Encrypt the essage using the RSA public key
    func RSAEncrypt(message : String) -> String{
        //step1 : convertire il plaintext in utf8
        let plainTextData = [UInt8](message.utf8)
        //step2 : ricavare la lunghezza del testo in utf8
        let plainTextDataLength = UInt(plainTextData.count)
        //step3 : creare il buffer per il testo criptato
        var encryptedData = [UInt8](count: self.blockSize, repeatedValue: 0)
        //step4 : criptare
        SecKeyEncrypt(self.publicKey as SecKey!, SecPadding(kSecPaddingPKCS1) as SecPadding,  plainTextData, Int(plainTextDataLength), &encryptedData, &self.blockSize)
        var base64 = NSData(bytes: encryptedData, length: encryptedData.count).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        //ritorniamo il cipher
        return base64
        
    }
    
    /// Decrypt the message using RSA private key
    func RSADecrypt(encryptedDataBase64 : String) -> String{
        
        let base64dec = NSData(base64EncodedString: encryptedDataBase64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
        //prepariamo il buffer da riempire
        var buffer = [UInt8]()
        //referenza ai byte del cipher
        let bytes = UnsafePointer<UInt8>(base64dec.bytes)
        //riempiamo il buffer
        for i in 0 ..< base64dec.length
        {
            buffer.append(bytes[i])
        }
        //step1 : creare il buffer per i dati decriptati
        var decryptedData = [UInt8](count: self.blockSize, repeatedValue: 0)
        
        //decriptare
        SecKeyDecrypt(privateKey, SecPadding(kSecPaddingPKCS1), buffer, self.blockSize, &decryptedData, &self.blockSize)
        
        let decryptedText = String(bytes: decryptedData, encoding:NSUTF8StringEncoding)
        //ritorniamo il plain
        return decryptedText!
    }
    
    func send(){
        
        var http = HttpReqWraper()
        
        
        //query paramenters
        let query: [String: AnyObject] = [
            kSecClass as! String : kSecClassKey as! String,
            kSecAttrKeyType as! String : kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as! String: "com.tinfinity.crypto.publickey",
            kSecReturnRef as! String : true as Bool
        ]
        //get the reference to the publickey
        var keyPtr: Unmanaged<AnyObject>?
        //get bytes
        let result = SecItemCopyMatching(query, &keyPtr)
        //create a data object
        var publickeyData = NSData(bytes: &keyPtr!, length: self.blockSize)
        //encode it with base64
        var base64PublicKey = publickeyData.base64EncodedStringWithOptions(nil)
        
        println(base64PublicKey)
                    
        //http.post("http://localhost:3000/auth/register-step1", params: ["key" : self.publicKey!])
        
        
    }
    
    
}