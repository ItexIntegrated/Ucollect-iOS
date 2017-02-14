//
//  UcollectWKWebView.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 23/01/2017.
//  Copyright © 2017 Itex Integrated Services. All rights reserved.
//

import UIKit
import WebKit

class UcollectWKWebView: WKWebView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
 
    
    required init?(coder: NSCoder) {
        
        if let _view = UIView(coder: coder) {
//            super.init(frame: _view.frame, configuration: WKWebViewConfiguration())
//            
//            bounds = frame
//            //autoresizingMask = _view.autoresizingMask
//            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            
            super.init(frame: .zero, configuration: WKWebViewConfiguration())
            
            translatesAutoresizingMaskIntoConstraints = false
            let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: _view, attribute: .height, multiplier: 1, constant: 0)
            let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: _view, attribute: .width, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: self, attribute: .leftMargin, relatedBy: .equal, toItem: _view, attribute: .leftMargin, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: self, attribute: .rightMargin, relatedBy: .equal, toItem: _view, attribute: .rightMargin, multiplier: 1, constant: 0)
            let bottomContraint = NSLayoutConstraint(item: self, attribute: .bottomMargin, relatedBy: .equal, toItem: _view, attribute: .bottomMargin, multiplier: 1, constant: 0)
            _view.addConstraints([height, width, leftConstraint, rightConstraint, bottomContraint])
            

            
        } else {
            return nil
        }
    }
    
  
    
 
    
    func loadUrl(string: String) {
        if let url = URL(string: string) {
            load(URLRequest(url: url))
        }
    }
    
   
}
