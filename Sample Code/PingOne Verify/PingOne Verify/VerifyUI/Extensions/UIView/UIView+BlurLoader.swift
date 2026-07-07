//
//  UIView+BlurLoader.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/17/22.
//

import Foundation
import UIKit

extension UIView {
    func showBlurLoader() {
        let blurLoader = BlurLoader(frame: frame)
        self.addSubview(blurLoader)
    }

    func removeBlurLoader() {
        if let blurLoader = subviews.first(where: { $0 is BlurLoader }) {
            blurLoader.removeFromSuperview()
        }
    }
}
