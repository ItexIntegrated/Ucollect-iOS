//
//  ViewController.swift
//  UcollectTestApp
//
//  Created by Ayodeji Bamitale on 20/01/2017.
//  Copyright © 2017 Itex Integrated Services. All rights reserved.
//

import UIKit
import Ucollect


class ViewController: UIViewController, TransactionCallback{
    
    
    let merchantID  = "cipgubatest"
    let merchantKey = "b4a4808d-9f36-4404-8ffb-f4fb4952dcbc"
    
    
    @IBOutlet weak var cardNumberText: UITextField!
    @IBOutlet weak var cardHolderNameText: UITextField!
    
    @IBOutlet weak var expiryMonthText: UITextField!
    @IBOutlet weak var expiryYearText: UITextField!
    
    @IBOutlet weak var cvvText: UITextField!
    @IBOutlet weak var pinText: UITextField!
    
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIView!
    
    
    
    var requestManager : RequestManager!
    
    public required init?(coder: NSCoder){
        
        
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //progressIndicator.startAnimating()
        progressView.isHidden =  true
        
        self.requestManager =  try? RequestManager.initialize(context: self, merchantID: merchantID, merchantKey: merchantKey)
        
        let gestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startTransactionProcess(_ sender: Any) {
        
        buildRequest()
        if(requestManager == nil){
            showMessage(title: "Error", message: "Invalid Parameters")
            return
        }
        
        
        showProgress(show: true)
        requestManager?.startPaymentTransaction(transactionCallback: self)
        
    }
    

    
    func onRequestOtpAuthorization() {
        showProgress(show: false)
        
        let inputController = UIAlertController(title: "Authorization Request", message: "Enter OTP", preferredStyle: .alert)
        
        inputController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
            textField.placeholder = "Enter OTP"
        }
        
        inputController.addAction(UIAlertAction(title: "Authorize", style: .default, handler: { (action) in
            self.showProgress(show: true)
            self.requestManager.authorizeTransaction(otp: (inputController.textFields?[0].text!)!)
        }))
        
        inputController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.showProgress(show: true)
            self.requestManager.queryTransactionStatus(merchantGeneratedReferenceNumber: self.requestManager.merchantGeneratedReferenceNumber, resultCallback: self)
        }))
        
        self.show(inputController, sender: nil)

    }
    
    func onTransactionError(error: Error) {
        showProgress(show: false)
        showMessage(title: "Transaction Failed", message: "\(error)")
        print(error)
    }
    
    func onTransactionComplete(result: TransactionResult) {
        showProgress(show: false)
        let status =  Int(result.Status)
        
        let title = status == 0 ? "Transaction Successful" : "Transaction Declined"
        
        showMessage(title: title, message: result.Message)
        print(result.toJSON())
        
    }
    
    
    public  func buildRequest(){
        
        requestManager.workingMode = .DEBUG
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = RequestManager.UCOLLECT_DATE_FORMAT
        let convertedDate: String = dateFormatter.string(from: currentDate)
        
        requestManager.transactionDateTime = convertedDate;
        
        //Customer Info
        requestManager.customerLastName = "Aleke";
        requestManager.customerFirstName = "Godwin";
        requestManager.customerEmail = "test@test.com";
        requestManager.customerPhoneNumber = "08085555643";
        
        //Payment Info
        requestManager.countryCurrencyCode = "566";
        requestManager.totalPurchaseAmount = 50000.0;
        requestManager.numberOfItems = 5;
        requestManager.purchaseDescription = "Buns Purchase";
        requestManager.merchantGeneratedReferenceNumber = "\((UInt)(NSDate().timeIntervalSince1970 * 1000))"
        
        
        //Card Details
        requestManager.cardPan = cardNumberText.text!
        requestManager.cardCVV = cvvText.text!
        requestManager.cardExpiryMonth = Int(expiryMonthText.text!)!
        requestManager.cardExpiryYear = Int(expiryYearText.text!)!
        requestManager.cardHolderName = cardHolderNameText.text!
        if let pin = pinText.text{
            requestManager.cardPin = pin
        }

    
        
        
    }
    
    
    func showProgress(show: Bool){
        
        show ? progressIndicator.startAnimating(): progressIndicator.stopAnimating()
        
        progressView.isHidden = !show
        
    }
    
    
    func showMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
            self.dismiss(animated: false, completion: nil)
        }))
        
        
        self.show(alertController, sender: nil)
    }
    
    
}

