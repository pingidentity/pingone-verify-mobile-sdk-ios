//
//  UIColor+loadColor.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/30/23.
//

import Foundation
import UIKit

extension UIColor {
    static func loadColor(named: String) -> UIColor? {
        if let colorFromMain = UIColor(named: named, in: Bundle.main, compatibleWith: nil) {
            return colorFromMain
        }
        if let colorFromVerifyUI = UIColor(named: named, in: Bundle(for: BaseViewController.self), compatibleWith: nil) {
            return colorFromVerifyUI
        }
        if let colorFromPingOneVerify = UIColor(named: named, in: Bundle(for: PingOneVerifyClient.self), compatibleWith: nil) {
            return colorFromPingOneVerify
        }
        return nil
    }
}
