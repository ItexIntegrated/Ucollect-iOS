//
//  ResultCallback.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 07/02/2017.
//  Copyright © 2017 Itex Integrated Services. All rights reserved.
//

import Foundation

public protocol ResultCallback{
    func onTransactionError(error: Error);
    
    func onTransactionComplete(result: TransactionResult);
}
