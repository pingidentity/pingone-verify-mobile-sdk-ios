//
//  PhoneCaptureUtils.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 4/14/23.
//

import Foundation
import UIKit

class PhoneCaptureUtils {
    static func isValidPhoneNumber(phoneNumber: String) -> Bool {
        //need to update to better validation
        return phoneNumber.count > 5
    }
    
    static func isValidCountryCode(countryCode: String) -> Bool {
        let regex = "^[+]{0,1}+[0-9]{1,4}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: countryCode)
    }
}
