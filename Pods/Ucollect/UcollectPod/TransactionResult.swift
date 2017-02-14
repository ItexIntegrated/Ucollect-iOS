//
//  TransactionResult.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 16/12/2016.
//  Copyright © 2016 Itex Integrated Services. All rights reserved.
//

import Foundation
import ObjectMapper

public class TransactionResult : Mappable{
   public var Transref = ""
   public var Amount = ""
   public var Status = ""
   public var Message = ""
   public  var Pan = ""
    
    
    required public init?(map: Map) {
        
    }
    
     public func mapping(map: Map) {
        
        Transref <- map["result.Transref"]
        Amount <- map["result.Amount"]
        Status <- map["result.Status"]
        Message <- map["result.Message"]
        Pan <- map["result.Pan"]
    }
    
}
