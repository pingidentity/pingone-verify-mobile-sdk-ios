//
//  TicketEntryViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/24/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

class TicketEntryViewController: UIViewController {
    
    @IBOutlet weak var ticketIdTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    var parentScannerVc: QRScannerViewController?
    
    @IBAction func onVerifyClicked(_ sender: UIButton) {
        sender.preventRepeatedClicks()
        self.view.endEditing(true)
        guard let code = self.ticketIdTextField.text, code.count == 12,
              IdvHelper.hasRequiredInfo() else {
            UIApplication.showErrorAlert(title: "missing_info_error_title".localized, message: "missing_info_error_message".localized, alertAction: nil)
            return
        }
        print("Submitting request for code: \(code)")
        IdvHelper.shared.submitVerificationData(ticketId: code, qrUrl: nil)
        
        self.ticketIdTextField.text = "";
        self.dismiss(animated: true) {
            self.parentScannerVc?.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func onEditingChanged(_ sender: UITextField) {
        self.verifyButton.isEnabled = sender.text != nil && sender.text!.count == 12
    }
    
    @IBAction func onCancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension TicketEntryViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.onVerifyClicked(self.verifyButton)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
}
