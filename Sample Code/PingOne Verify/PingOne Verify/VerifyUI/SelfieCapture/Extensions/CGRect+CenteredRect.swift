//
//  CGRect+CenteredRect.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/31/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import AVFoundation

extension CGRect {

    func getCenteredSubRectWith(xMargin: CGFloat, yMargin: CGFloat) -> CGRect {
        let x = xMargin == 0 ? self.origin.x : max(self.origin.x, self.midX - xMargin)
        let y = yMargin == 0 ? self.origin.y : max(self.origin.y, self.midY - yMargin)
        let width = xMargin == 0 ? self.width : min(self.width, 2 * xMargin)
        let height = yMargin == 0 ? self.height : min(self.height, 2 * yMargin)
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}
