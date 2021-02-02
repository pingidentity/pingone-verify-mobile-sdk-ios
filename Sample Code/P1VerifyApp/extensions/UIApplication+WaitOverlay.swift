//
//  UIApplication+WaitOverlay.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/23/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func showWaitOverlay(message: String, cancelable: Bool = false, onCancelClicked: ((UIButton) -> ())? = nil) {
        WaitOverlayView.show(frame: UIScreen.main.bounds, message: message, cancelable: cancelable, onCancelClicked: onCancelClicked)
    }
    
    class func hideWaitOverlay() {
        WaitOverlayView.hide()
    }
    
}
