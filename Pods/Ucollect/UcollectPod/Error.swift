//
//  TransactionError.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 22/12/2016.
//  Copyright © 2016 Itex Integrated Services. All rights reserved.
//

import Foundation


public enum UcollectError : Error{
    case InitializationError(message: String)
    case TransactionError(message: String)
    
    
    func localizedDescription() -> String{
        switch(self){
        case .InitializationError(let message):
            return message
            
        case .TransactionError(let message):
            return message
            
        }
       
    }
    
    
}
