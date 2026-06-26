//
//  UIButton+preventRepeatedClicks.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 10/25/22.
//

import Foundation
import UIKit

extension UIButton {
    
    public func preventRepeatedClicks(inNext seconds: TimeInterval = 2) {
        self.isUserInteractionEnabled = false
        self.alpha = 0.5
        self.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.isUserInteractionEnabled = true
            self.alpha = 1.0
            self.isEnabled = true
        }
    }
    
}
