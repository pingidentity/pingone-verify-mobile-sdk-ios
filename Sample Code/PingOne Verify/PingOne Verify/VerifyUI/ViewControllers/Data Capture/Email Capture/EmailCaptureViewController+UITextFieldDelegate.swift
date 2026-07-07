//
//  EmailCaptureViewController+UITextFieldDelegate.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 4/14/23.
//

import Foundation
import UIKit

extension EmailCaptureViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.canSendVerificationCode = self.canSubmitValidData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.canSendVerificationCode = self.canSubmitValidData()
        
        return true
    }
    
    @objc func hideKeyboard(_ sender: Any?) {
        if let dataTextField = self.dataTextField {
            dataTextField.resignFirstResponder()
        }
    }
}
