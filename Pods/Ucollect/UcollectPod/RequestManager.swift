//
//  RequestManager.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 13/12/2016.
//  Copyright © 2016 Itex Integrated Services. All rights reserved.
//

import Foundation
import ObjectMapper
import IDZSwiftCommonCrypto
import BoltsSwift
import UIKit

public final class RequestManager{
    
    static var instance: RequestManager!
    
    public static  let UCOLLECT_DATE_FORMAT = "dd/MM/yyyy HH:mm:ss"
    
    private var merchantID: String!, serviceKey: String!, encKey: String!;
    
    public var  workingMode = MODE.LIVE;
    
    public var purchaseDescription = "",
    transactionDateTime = "", // format dd/MM/yyyy hh:mm:ss
    countryCurrencyCode = "", merchantGeneratedReferenceNumber = "";
    
    public var totalPurchaseAmount : Double;
    public var numberOfItems: Int;
    public var customerFirstName = "", customerLastName = "",
    customerEmail = "", customerPhoneNumber = "";
    
    public var cardPan = ""
    
    public var cardCVV = "", cardExpiryMonth = 0, cardExpiryYear = 0, cardHolderName = "", cardPin = "";
    
    private var otpString = "";
    private var orderID = "";
    private var context : UIViewController!
    
    var  callBack: ResultCallback!;
    
    
    
    
    private init(){
        totalPurchaseAmount = 0.0;
        numberOfItems = 0;
        
    }
    
    
    static func getInstance() -> RequestManager{
        if(instance == nil){
            instance = RequestManager()
        }
        
        assert(instance != nil)
        return instance;
    }
    
    static func normalize(data: String) throws -> String{
        
        let newData =  data.replacingOccurrences(of: "_", with: "").replacingOccurrences(of: "-", with: "").uppercased().trimmingCharacters(in: CharacterSet.whitespaces);
        
        if(32 != newData.characters.count){
            throw UcollectError.InitializationError(message: "Invalid Merchant Key")
        }
        
        
        return newData
    }
    
    
    public static func initialize(context: UIViewController, merchantID: String , merchantKey: String) throws -> RequestManager{
        
        instance = getInstance()
        
        instance.serviceKey = merchantKey
        instance.merchantID = merchantID
        instance.context =  context
        
        
        guard let tempKey =  try? normalize(data: merchantKey) else{
            throw UcollectError.InitializationError(message: "Invalid Merchant Key")
        }
        
        guard let finalKeyString =  try? KeyCrypto.tripleDesEncryptEcb(key: tempKey, data: arrayFrom(hexString:tempKey)) else{
            throw UcollectError.InitializationError(message: "Invalid Merchant Key")
        }
        
        instance.encKey =  finalKeyString
        
        
        instance.workingMode = .LIVE
        
        return instance;
    }
    
    
    func buildTransactionRequest() -> String?{
        let jsonRequest : NSMutableDictionary = NSMutableDictionary()
        
        jsonRequest.setValue(self.merchantID!, forKey: "merchantId")
        jsonRequest.setValue(self.purchaseDescription, forKey: "description")
        jsonRequest.setValue(self.totalPurchaseAmount, forKey: "total")
        jsonRequest.setValue(self.transactionDateTime, forKey: "date")
        jsonRequest.setValue(self.countryCurrencyCode, forKey: "countryCurrencyCode")
        jsonRequest.setValue(self.numberOfItems, forKey: "noOfItems")
        
        jsonRequest.setValue(self.customerFirstName, forKey: "customerFirstName")
        jsonRequest.setValue(self.customerLastName, forKey: "customerLastname")
        jsonRequest.setValue(customerEmail, forKey: "customerEmail")
        jsonRequest.setValue(self.customerPhoneNumber, forKey: "customerPhoneNumber")
        
        jsonRequest.setValue(self.merchantGeneratedReferenceNumber, forKey: "referenceNumber")
        jsonRequest.setValue(self.serviceKey!, forKey: "serviceKey")
        
        
        let cardDetails = "\(cardPan)|\(cardCVV)|\(cardExpiryYear)|\(cardExpiryMonth)|\(cardPin)|\(cardHolderName)";
        
        
        guard let encryptedDetails = encryptData(data: cardDetails) else{
            return nil
        }
        
        
        jsonRequest.setValue(encryptedDetails, forKey: "detail")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonRequest, options: JSONSerialization.WritingOptions.prettyPrinted) else{
            return nil
        }
        
        let requestString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String
        
        return requestString
    }
    
    func buildVerificationRequest() -> String?{
        
        let jsonObject :NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(self.merchantID!, forKey: "mid")
        jsonObject.setValue(self.merchantGeneratedReferenceNumber, forKey: "rid")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted) else{
            return nil
        }
        
        let requestString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String
        
        return requestString
        
    }
    
    func buildAuthorizationRequest() -> String?{
        
        let jsonObject :NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(self.orderID, forKey: "oID")
        jsonObject.setValue(self.otpString, forKey: "otp")
        
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted) else{
            return nil
        }
        
        let requestString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String
        
        return requestString
        
    }
    
    func encryptData(data: String) -> String?{
        guard let output = try? KeyCrypto.tripleDesEncryptEcbData(key: self.encKey, data: Array(data.utf8)) else{
            return nil
        }
        return output
    }
    
    
    public func startPaymentTransaction(transactionCallback: TransactionCallback){
        callBack =  transactionCallback
        
        CipgProcessor.initiateTransaction().continueOnSuccessWith(Executor.mainThread) { (status) -> Void in
            
            if(status.Status == "000"){
                self.queryTransactionStatus();
            }
            else if(status.Status == "001"){
                
                if(status._Type == "UPSL"){
                    let url = status.PinpadURL;
                    self.doWebProcess(pinPadUrl: url)
                } else if(status._Type == "VERVE"){
                    
                    self.orderID = status.OrderID;
                    (self.callBack as? TransactionCallback)?.onRequestOtpAuthorization();
                    
                }else{
                    throw  UcollectError.TransactionError(message: "Error: No process defined for this flow");
                }
                
            }
            else{
                throw  UcollectError.TransactionError(message: status.Message);
            }
            
            }.continueWith(Executor.mainThread) { (task) -> Void in
                if task.faulted{
                    let error =  task.error!
                    self.callBack.onTransactionError(error: error)
                }
        }
    }
    
    
    
    
    public func authorizeTransaction(otp: String){
        self.otpString = otp
        
        CipgProcessor.authorizeTransaction().continueOnSuccessWith { (status) -> Void in
            if status.Status == "000"{
                self.queryTransactionStatus()
            }else{
                throw  UcollectError.TransactionError(message: status.Message)
            }
            }.continueWith { (task) -> Void in
                if task.faulted{
                    let error =  task.error!
                    self.callBack.onTransactionError(error: error)
                }
        }
    }
    
    
    func queryTransactionStatus(){
        CipgProcessor.verifyTransactionStatus().continueOnSuccessWith(Executor.mainThread) { (transactionResult) -> Void in
            self.callBack.onTransactionComplete(result: transactionResult)
            }.continueWith(Executor.mainThread) { (task) -> Void in
                if task.faulted{
                    let error =  task.error!
                    self.callBack.onTransactionError(error: error)
                }
        }
    }
    
    public func queryTransactionStatus(merchantGeneratedReferenceNumber: String, resultCallback: ResultCallback){
        self.merchantGeneratedReferenceNumber = merchantGeneratedReferenceNumber
        callBack = resultCallback
        queryTransactionStatus()
    }
    
    
    func doWebProcess(pinPadUrl: String){
        
        let bundle = WebViewController.bundle
        let storyBoard =  UIStoryboard(name: "UStoryboard", bundle: bundle )
        
        let webController =  storyBoard.instantiateInitialViewController() as! WebViewController//storyBoard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        
        webController.urlString =  pinPadUrl
        
      
        context.present(webController, animated: false, completion: nil)
    }
    
    
    
    public enum MODE{
        case DEBUG, LIVE
    }
    
    
    class Status : Mappable {
        public var Message = "";
        public var Status = "";
        public var _Type  = "";
        public var OTP  = "";
        public var OrderID = "";
        public var PinpadURL = "";
        
        
        required public init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
          
            
            self.Message <- map["result.Message"]
            self.Status <- map["result.Status"]
            self._Type <- map["result.Type"]
            self.OTP <- map["result.OTP"]
            self.OrderID <- map["result.OrderID"]
            self.PinpadURL <- map["result.PinpadURL"]
        }
    }
}
