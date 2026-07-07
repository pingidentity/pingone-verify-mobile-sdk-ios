//
//  UITextField+changeErrorBorder.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 2/23/23.
//

import Foundation
import UIKit

extension UITextField {
    func changeErrorBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.red.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}
