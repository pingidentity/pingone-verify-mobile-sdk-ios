//
//  PhoneCaptureViewController+CustomCountryCodePickerListener.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 7/19/23.
//

import Foundation

extension PhoneCaptureViewController: CustomCountryCodePickerListener {
    func onCountryCodePicked(code: String) {
        self.customPhoneView.countryCodeTextField.text = code
    }
}
