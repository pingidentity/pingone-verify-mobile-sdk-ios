//
//  UIView+Border.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable var viewBorderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var viewBorderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var viewCornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}
