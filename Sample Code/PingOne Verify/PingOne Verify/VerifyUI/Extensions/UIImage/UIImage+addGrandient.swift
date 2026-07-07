//
//  UIImage+addGrandient.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 5/11/22.
//

import Foundation
import UIKit

extension UIImage {
    func addGradient(color: UIColor, gradientFactor: Double) -> UIImage {
        let startColor = CGColor(red: color.redValue / gradientFactor, green: color.greenValue / gradientFactor, blue: color.blueValue / gradientFactor, alpha: color.alphaValue)
        let endColor = CGColor(red: color.redValue * gradientFactor, green: color.greenValue * gradientFactor, blue: color.blueValue * gradientFactor, alpha: color.alphaValue)
        
        let gradientImage = self.tintedWithLinearGradientColors(colorsArr: [startColor, endColor])
        return gradientImage
    }
}
