//
//  SCSmartAESCode.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/5.
//

import UIKit
import CryptoSwift
import CommonCrypto

fileprivate let AESDefaultkey = "1234567890123456"
fileprivate let kInitVector = "A-16-Byte-String"

class SCSmartAESCode {
    
    private static func aesEncrypt(data: Data, key: String = AESDefaultkey) -> Data {
        let keyData = key.data(using: .utf8) ?? Data()
        let encrptedData = cipherOperation(contentData: data, keyData: keyData, operation: CCOperation(kCCEncrypt))
//        let enData = aesEncryptData(data, keyData)
        return encrptedData ?? Data()
    }
    
    public static func aesEncrypt(content: String, key: String = AESDefaultkey) -> String {
        let contentData = content.data(using: .utf8) ?? Data()
        let encrptedData = self.aesEncrypt(data: contentData, key: key)
        let encrptedString = encrptedData.base64EncodedString(options: Foundation.Data.Base64EncodingOptions.endLineWithLineFeed)
//        let enString = aesEncryptString(content, key)
        return encrptedString
    }
    
    private static func aesDecrypt(data: Data, key: String = AESDefaultkey) -> Data {
        let keyData = key.data(using: .utf8) ?? Data()
        let decryptedData = cipherOperation(contentData: data, keyData: keyData, operation: CCOperation(kCCDecrypt))
//        let deData = aesDecryptData(data, keyData)
        return decryptedData ?? Data()
    }
    
    public static func aesDecrypt(content: String, key: String = AESDefaultkey) -> String {
        let contentData = Data(base64Encoded: content, options: .ignoreUnknownCharacters) ?? Data()
        let decryptedData = self.aesDecrypt(data: contentData, key: key)
        let decryptedString = String(data: decryptedData, encoding: .utf8)
//        let decryptedString = aesDecryptString(content, key)
        return decryptedString ?? ""
    }
    
    
    
    private static func cipherOperation(contentData: Data, keyData: Data, operation: CCOperation) -> Data? {
        let contentLength = contentData.count
        
        let initVectorBytes = kInitVector.data(using: .utf8)?.bytes ?? []
        let contentBytes = contentData.bytes
        let keyBytes = keyData.bytes
        
        let keySize = kCCKeySizeAES128
        let operationSize = contentLength + kCCBlockSizeAES128
//        var operationBytes: [UInt8] = [UInt8].init(repeating: 0, count: operationSize)
        let operationBytes = UnsafeMutableRawPointer.allocate(byteCount: operationSize, alignment: 0)
        var actualOutSize: Int = 0
        
        
        let cryptStatus = CCCrypt(operation, CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode), keyBytes, keySize, initVectorBytes, contentBytes, contentLength, operationBytes, operationSize, &actualOutSize)
        
        if cryptStatus == kCCSuccess {
            let data = Data(bytes: operationBytes, count: actualOutSize)
            operationBytes.deallocate()
            return data
        }
        return nil
    }
}






