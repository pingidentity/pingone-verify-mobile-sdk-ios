//
//  UIImage+loadImage.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/9/23.
//

import Foundation
import UIKit

extension UIImage {
    static func loadImage(named: String) -> UIImage? {
        if let imageFromMain = UIImage(named: named, in: Bundle.main, compatibleWith: nil) {
            return imageFromMain
        }
        if let imageFromVerifyUI = UIImage(named: named, in: Bundle(for: BaseViewController.self), compatibleWith: nil) {
            return imageFromVerifyUI
        }
        if let imageFromPingOneVerify = UIImage(named: named, in: Bundle(for: PingOneVerifyClient.self), compatibleWith: nil) {
            return imageFromPingOneVerify
        }
        return nil
    }
}
