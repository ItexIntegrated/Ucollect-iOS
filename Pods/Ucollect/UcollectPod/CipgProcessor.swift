//
//  CipgProcessor.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 16/12/2016.
//  Copyright © 2016 Itex Integrated Services. All rights reserved.
//

import Foundation
import BoltsSwift
import Alamofire
import AlamofireObjectMapper


class CipgProcessor{
    
    
    static let serverTrustPolicies: [String: ServerTrustPolicy] = [
        //        "test.example.com": .pinCertificates(
        //            certificates: ServerTrustPolicy.certificatesInBundle(),
        //            validateCertificateChain: true,
        //            validateHost: true
        //        ),
        "databaseendsrv.cloudapp.net": .disableEvaluation
    ]
    
    static let sessionManager = SessionManager(
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
    )
    
    private static func  buildAlamofireRequest(urlString: String, requestString : String) -> DataRequest{
        
    
        let url =  URL(string: urlString)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("text/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = requestString.data(using: String.Encoding.utf8)
        return sessionManager.request(urlRequest)
        
    }
    
    static func initiateTransaction() -> Task<RequestManager.Status>{
        
        let rm =  RequestManager.getInstance()
        
        let task = TaskCompletionSource<RequestManager.Status>();
        
        let urlString = rm.workingMode == .DEBUG ? Constants.DEBUG_URL : Constants.LIVE_URL
        let content = rm.buildTransactionRequest()!
        
        let request = buildAlamofireRequest(urlString: urlString, requestString: content)
        request.responseObject{ (response: DataResponse<RequestManager.Status>) in
            
            let result =  response.result
            if let error =  result.error{
                task.set(error: error)
                return
                
            }else if let status =  result.value{
                task.set(result: status)
            }else{
                task.cancel()
            }
            
            
        }
        return task.task
        
    }
    
    static func verifyTransactionStatus() -> Task<TransactionResult>{
        
        let object = TaskCompletionSource<TransactionResult>();
        let rm =  RequestManager.getInstance()
        
        let urlString = rm.workingMode == .DEBUG ? Constants.DEBUG_STATUS_URL : Constants.LIVE_STATUS_URL
        
        let request = buildAlamofireRequest(urlString: urlString, requestString: rm.buildVerificationRequest()!)
        request.responseObject{ (response: DataResponse<TransactionResult>) in
            
            let result =  response.result
            if let error =  result.error{
                object.set(error: error)
                return
                
            }else if let transactionResult =  result.value{
                object.set(result: transactionResult)
            }else{
                object.cancel()
            }
            
        }
        
        
        return object.task
    }
    
    
    static func authorizeTransaction() -> Task<RequestManager.Status>{
        let object = TaskCompletionSource<RequestManager.Status>();
        
        let rm =  RequestManager.getInstance()
        
        let urlString = rm.workingMode == .DEBUG ? Constants.DEBUG_OTP_URL : Constants.DEBUG_OTP_URL
        
        let request = buildAlamofireRequest(urlString: urlString, requestString: rm.buildAuthorizationRequest()!)
        request.responseObject{ (response: DataResponse<RequestManager.Status>) in
            
            let result =  response.result
            if let error =  result.error{
                object.set(error: error)
                return
                
            }else if let status =  result.value{
                object.set(result: status)
            }else{
                object.cancel()
            }
            
        }
        
        return object.task
    }
    
    
    
    
    
    
}
