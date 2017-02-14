//
//  KeyCrypto.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 06/01/2017.
//  Copyright © 2017 Itex Integrated Services. All rights reserved.
//

import Foundation
import IDZSwiftCommonCrypto


 class KeyCrypto{
    
    var key: Array<UInt8>
    var algorithm : Cryptor.Algorithm
    var options: Cryptor.Options
    var cryptor: Cryptor!
    let iv : [UInt8] = Array(repeating: 0, count: 16)
    
    
 init(key: String,algorithm: Cryptor.Algorithm, options: Cryptor.Options){
        
        self.algorithm = algorithm
        self.options = options
        
        if(algorithm == .tripleDES){
            if key.characters.count == 32{
                let temp = KeyCrypto.pad3DES(key)
                self.key = arrayFrom(hexString: temp)
            }else {
                self.key =  arrayFrom(hexString: key)
            }
        }else{
            self.key =  arrayFrom(hexString: key)
        }
        
    }
    
     func encryptData(clearText dataString: String) throws -> String{
        cryptor = Cryptor(operation:.encrypt, algorithm: algorithm, options:options, key:key, iv: iv)
    
        
        guard let encData =  cryptor.update(string: dataString)?.final() else{
            throw CryptoError.EncryptionError(message: "Encryption failed")
        }
        
            //print("Encrypted Byte Array: \(encData)")
            
            let cipherText =  hexString(fromArray: encData)
            //print("Cipher Text: \(cipherText)")
            
            return cipherText
        
        
    }
    
    
     func decryptData(cipherText dataString: String) throws -> String{
        
        cryptor = Cryptor(operation:.decrypt, algorithm: algorithm, options:options, key:key, iv: iv)
        
        let data = arrayFrom(hexString: dataString)
        
        guard let decData = cryptor.update(byteArray: data)?.final()else{
            throw CryptoError.DecryptionError(message: "Decryption failed")
        }
            
            let clearText = decData.reduce("") { $0 + String(UnicodeScalar($1)) }
            return clearText
       
    }
    
     static func byteArrayToString(data : Array<UInt8>) -> String {
        
        let clearText = data.reduce("") { $0 + String(UnicodeScalar($1)) }
        return clearText
    }
    
    
    static func pad3DES(_ str: String) -> String{
        
        let substr =  str.substring(to: str.index(str.startIndex, offsetBy: 16))
        
        return str + substr;
        
    }
    
     static func tripleDesEncryptEcb(key: String, data: Array<UInt8>) throws -> String{
        let tempKey =  prepareKey(key)
    
        let iv: [UInt8] = Array.init(repeating: 0, count: 8)
        
        let tempCryptor = Cryptor(operation: .encrypt, algorithm: .tripleDES, mode:  StreamCryptor.Mode.ECB, padding: StreamCryptor.Padding.NoPadding, key: arrayFrom(hexString: tempKey), iv: iv)
        
        guard let finalKey = tempCryptor.update(byteArray: data)?.final() else{
            throw KeyCrypto.CryptoError.EncryptionError(message: "Encryption failed")
        }
        
        let finalKeyString = hexString(fromArray: finalKey, uppercase: true)
        
        return finalKeyString
    }
    
     static func tripleDesEncryptEcbData(key: String, data: Array<UInt8>) throws -> String{
        
        let tempKey =  prepareKey(key)
       
        
        let iv: [UInt8] = Array.init(repeating: 0, count: 8)
        
        let tempCryptor = Cryptor(operation: .encrypt, algorithm: .tripleDES, mode:  StreamCryptor.Mode.ECB, padding: StreamCryptor.Padding.PKCS7Padding, key: arrayFrom(hexString: tempKey), iv: iv)
        
        guard let finalKey = tempCryptor.update(byteArray: data)?.final() else{
            throw KeyCrypto.CryptoError.EncryptionError(message: "Encryption failed")
        }
        
        let finalKeyString = hexString(fromArray: finalKey, uppercase: true)
        
        return finalKeyString
    }
    
    
     static func tripleDesDecryptEcb(key: String, data: Array<UInt8>) throws -> Array<UInt8>{
        let tempKey =  prepareKey(key)
        
        
        let iv: [UInt8] = Array.init(repeating: 0, count: 8)
        
        let tempCryptor = Cryptor(operation: .decrypt, algorithm: .tripleDES, mode:  StreamCryptor.Mode.ECB, padding: StreamCryptor.Padding.PKCS7Padding, key: arrayFrom(hexString: tempKey), iv: iv)
        
        guard let finalKey = tempCryptor.update(byteArray: data)?.final() else{
            throw KeyCrypto.CryptoError.DecryptionError(message: "Decryption failed")
        }
        
        return finalKey
    }

    
    static func prepareKey(_ key: String) -> String{
        var tempKey =  key.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if(tempKey.characters.count !=  48){
            tempKey =  KeyCrypto.pad3DES(tempKey)
        }

        return tempKey
    }
    
    
     enum CryptoError : Error{
        case KeyCryptoError(message: String)
        case EncryptionError(message: String)
        case DecryptionError(message: String)
    }
    
    
}
