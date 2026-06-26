//
//  UILabel+textWidth.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/25/22.
//

import Foundation
import UIKit

extension UILabel {
    class func textWidth(font: UIFont? = nil, text: String) -> CGFloat {
        return textSize(font: font, text: text).width
    }

    class func textSize(font: UIFont?, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        if let font = font {
            label.font = font
        }
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }
}
