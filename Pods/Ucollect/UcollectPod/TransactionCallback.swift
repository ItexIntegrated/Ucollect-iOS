//
//  ITransactionCallback.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 16/12/2016.
//  Copyright © 2016 Itex Integrated Services. All rights reserved.
//

import Foundation


public protocol TransactionCallback : ResultCallback{
    
    func onRequestOtpAuthorization();

}
