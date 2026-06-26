//
//  OtpViewController+UITextFieldDelegate.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/11/22.
//

import Foundation
import UIKit

extension OtpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String) -> Bool {
        // 1. Get the current text
        let currentText = textField.text ?? ""
        
        // 2. Calculate the "Future Text" (Current text + the change)
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 3. Enable submit once the entered length matches the server-specified length (or any
        //    non-empty input when the server did not specify a length).
        let requiredLength = self.otpSession?.otpLength
        let isReady = requiredLength.map { updatedText.count == $0 } ?? !updatedText.isEmpty
        self.submitButtonEnabled(value: isReady)
        
        // 4. Return true to let the text field update naturally
        return true
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.appForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self, let expiresAt = self.otpSession?.expiresAt else { return }
            self.otpSettings?.otpExpiryTicker.start(expiresAt: expiresAt)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let bottomSafeArea = view.safeAreaInsets.bottom
        self.submitPasscodeButtonBottomConstraint.constant = keyboardHeight - bottomSafeArea + 8
        UIView.animate(withDuration: DataCaptureConstants.KEYBOARD_ANIMATION_DURATION) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.submitPasscodeButtonBottomConstraint.constant = self.originalButtonBottomConstant
        UIView.animate(withDuration: DataCaptureConstants.KEYBOARD_ANIMATION_DURATION) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func hideKeyboard(_ sender: Any?) {
        self.otpTextField.resignFirstResponder()
    }
}

extension OtpViewController {
    func setUpConstraintsForSmallScreenDevices() {
        guard let submitPasscodeButtonBottomConstraint = submitPasscodeButtonBottomConstraint else { return }
        if isSmallScreenDevice() {
            submitPasscodeButtonBottomConstraint.constant = 80
        } else {
            submitPasscodeButtonBottomConstraint.constant = 180
        }
    }
    
    func isSmallScreenDevice() -> Bool {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return screenHeight <= DataCaptureConstants.SMALLER_DEVICES
    }
}
