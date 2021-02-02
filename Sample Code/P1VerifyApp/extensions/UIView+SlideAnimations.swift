//
//  UIView+SlideAnimations.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/24/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func slideOutFromBottom(duration: TimeInterval = 1.0, onComplete: (() -> Void)? = nil) {
        // Create a CATransition animation
        let slideOutFromBottomTransition = CATransition()
        
        slideOutFromBottomTransition.delegate = AnimationDelegate(onComplete: onComplete)
        
        // Customize the animation's properties
        slideOutFromBottomTransition.type = CATransitionType.push
        slideOutFromBottomTransition.subtype = CATransitionSubtype.fromTop
        slideOutFromBottomTransition.duration = duration
        slideOutFromBottomTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideOutFromBottomTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideOutFromBottomTransition, forKey: "slideInFromTopTransition")
        
    }
    
    func slideInFromTop(duration: TimeInterval = 1.0, onComplete: (() -> Void)? = nil) {
        // Create a CATransition animation
        let slideInFromTopTransition = CATransition()
        
        slideInFromTopTransition.delegate = AnimationDelegate(onComplete: onComplete)
        
        // Customize the animation's properties
        slideInFromTopTransition.type = CATransitionType.push
        slideInFromTopTransition.subtype = CATransitionSubtype.fromBottom
        slideInFromTopTransition.duration = duration
        slideInFromTopTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromTopTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromTopTransition, forKey: "slideOutFromBottomTransition")
    }
    
    class AnimationDelegate: NSObject, CAAnimationDelegate {
        
        var onComplete: (() -> Void)?
        
        init(onComplete: (() -> Void)?) {
            self.onComplete = onComplete
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            if (flag) {
                self.onComplete?()
            }
        }
        
    }
    
}

