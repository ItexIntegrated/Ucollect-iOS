//
//  WebViewController.swift
//  UcollectMobile
//
//  Created by Ayodeji Bamitale on 23/01/2017.
//  Copyright © 2017 Itex Integrated Services. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
 
    @IBOutlet weak var webkitView: UcollectWKWebView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressContainer: UIView!
    
    var upsl_process_complete =  false
    let requestManager = RequestManager.getInstance()
    
    static let nibNameString = "WebViewController"
    
    var urlString : String!
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    
//    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
//        
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        
//        
//    }
//    
//    convenience  init() {
//        self.init(nibName: nil, bundle: nil)
//    }
//    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressIndicator.hidesWhenStopped = true
        
        progressIndicator.startAnimating()
        
        
        webkitView.uiDelegate = self
        webkitView.navigationDelegate = self
        webkitView.allowsBackForwardNavigationGestures = false
        webkitView.allowsLinkPreview = false
//        webkitView.scrollView.isScrollEnabled = false
    
        
        webkitView.loadUrl(string: urlString!)
        
        showProgressIndicator(true)
        
    }
    
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //print("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print("didFinish")
        
        if(upsl_process_complete){
            exitAndContinueInBackground(view: webView)
        }else{
            showProgressIndicator(false)
            webView.isHidden = false
        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //print("didStartProvisionalNavigation")
        //print(webView.url!)
        
        if let url =  webView.url{
            switch (url.lastPathComponent) {
            case "uapprove.gsp", "udecline.gsp","ucancel.gsp":
                upsl_process_complete = true;
                break;
            default:
                upsl_process_complete = false
            }
        }
        
        showProgressIndicator(true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //print("didFail")
        exitAndContinueInBackground(view: webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //print("didFailProvisionalNavigation")
        //print(error)
        exitAndContinueInBackground(view: webView)
    }
    

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        
        completionHandler(.useCredential, cred)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        print("JS Alert")
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        print("JS Confirm")
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        print("JS Input")
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func exitAndContinueInBackground(view: WKWebView) {
        upsl_process_complete = false;
        view.stopLoading();
        showProgressIndicator(false)
        requestManager.queryTransactionStatus();
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func showProgressIndicator(_ shouldshow: Bool){
        
        
        progressContainer.isHidden = !shouldshow
        
        if(shouldshow){
            progressIndicator.isHidden = false
            progressIndicator.startAnimating()
            //webView.isHidden = true
            webkitView.isHidden = true
            
        }else{
            progressIndicator.stopAnimating()
        }
        
        
    }
    
    
    static var bundle:Bundle {
       
        let podBundle = Bundle(for: WebViewController.self)
        let bundleURL = podBundle.url(forResource: "Ucollect", withExtension: "bundle")
        
        return Bundle(url: bundleURL!)!
    }
    
    
    
}
