//
//  BorderedButton.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 2/23/23.
//

import Foundation
import UIKit

internal class BorderedButton: VerifyButton {
    
    @objc public dynamic var borderWidth: NSNumber? {
        set(width) {
            self.layer.borderWidth = CGFloat(width?.floatValue ?? 0)
        }
        get {
            return NSNumber(value: Float(self.layer.borderWidth))
        }
    }

    @objc public dynamic var borderColor: UIColor? {
        set(color) {
            self.layer.borderColor = color?.cgColor
        }
        get {
            return self.layer.borderColor == nil ? nil : UIColor(cgColor: self.layer.borderColor!)
        }
    }
    
}
