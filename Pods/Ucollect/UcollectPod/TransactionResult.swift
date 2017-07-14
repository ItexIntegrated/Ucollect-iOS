//
//  TransactionResult.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 16/12/2016.
//  Copyright © 2016 Itex Integrated Services. All rights reserved.
//

import Foundation
import ObjectMapper

public final class TransactionResult : Mappable{
    var Transref = ""
    var Amount = ""
    var Status = ""
    var Message = ""
    var Pan = ""
    var Details = ""
    
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
        Transref <- map["result.Transref"]
        Amount <- map["result.Amount"]
        Status <- map["result.Status"]
        Message <- map["result.Message"]
        Pan <- map["result.Pan"]
        Details <- map["result.Details"]
    }
    
    
    public func getTransactionReference() -> String{
        return Transref
    }
    
    public func getTransactionAmount() -> String{
        return Amount
    }
    
    public func getResponseMessage() -> String{
        return Message
    }
    
    public func getPan() -> String{
        return Pan
    }
    
    public func getDetails() -> String{
        return Details
    }
    
    public func getStatus() -> TransactionStatus{
        return  Status.trimmingCharacters(in: CharacterSet.whitespaces) == "000" ?  .APPROVED : .DECLINED
    }
    
    
}


public enum TransactionStatus{
    case APPROVED
    case DECLINED
}
