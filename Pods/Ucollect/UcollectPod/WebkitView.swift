//
//  WebkitView.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 09/02/2017.
//  Copyright © 2017 Itex Integrated Services. All rights reserved.
//

import UIKit
import WebKit

class WebkitView: UIView {
   
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var view: UIView!
    
    var webKitView : WKWebView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    
    func setup(){
        
        let nib =  UINib(nibName: "WebkitView", bundle: WebViewController.bundle)
        self.view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.view)
        
       
        let wkPrefs =  WKPreferences()
        wkPrefs.javaScriptEnabled = true
        // wkPrefs.javaScriptCanOpenWindowsAutomatically =  false
        
        let wkConfig =  WKWebViewConfiguration()
        wkConfig.preferences = wkPrefs
        
       
        
        webKitView = WKWebView(frame: self.view.frame, configuration: wkConfig)
        
        webKitView.bounds =  self.bounds
        webKitView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(webKitView)
    }
    
     func loadUrl(string: String) {
        if let url = URL(string: string) {
            webKitView.load(URLRequest(url: url))
        }
    }
    

}
