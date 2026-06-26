//
//  UINavigationController+interface.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 9/22/22.
//

import Foundation
import UIKit

extension UINavigationController {
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
