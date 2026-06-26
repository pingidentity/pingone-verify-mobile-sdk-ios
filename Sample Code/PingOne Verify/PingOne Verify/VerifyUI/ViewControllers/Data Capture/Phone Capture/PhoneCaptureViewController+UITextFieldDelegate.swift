//
//  PhoneCaptureViewController+UiTextFieldDelegate.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/11/22.
//

import Foundation
import UIKit

extension PhoneCaptureViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case self.customPhoneView.countryCodeTextField:
            DispatchQueue.main.async {
                self.view.endEditing(true)
                let customCountryPicker = CustomCountryPickerViewController.getViewController(countryCodePickerListener: self)
                customCountryPicker.title = "idv_countryCode_nav_title".localized
                
                self.navigationController?.pushViewController(customCountryPicker, animated: true)
            }
            
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.canSendVerificationCode = self.canSubmitValidData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.canSendVerificationCode = self.canSubmitValidData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else { return true }
        
        switch textField{
        case self.customPhoneView.phoneTextField:
            if string.count > 1 {
                if let countryCode = self.customPhoneView.countryCodeTextField.text {
                    text = string.replacingOccurrences(of: countryCode, with: "")
                } else {
                    text = string
                }
                
                textField.resignFirstResponder()
                textField.text = text
                self.canSendVerificationCode = self.canSubmitValidData()
                return false
            }
        default:
            return false
        }
        
        self.canSendVerificationCode = self.canSubmitValidData()
        return true
    }
    
    @objc func hideKeyboard(_ sender: Any?) {
        if let customPhoneView = self.customPhoneView, let phoneTextField = customPhoneView.phoneTextField {
            phoneTextField.resignFirstResponder()
        }
    }
}
