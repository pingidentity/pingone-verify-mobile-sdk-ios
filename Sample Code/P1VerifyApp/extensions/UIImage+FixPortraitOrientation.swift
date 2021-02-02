//
//  UIImage+FixPortraitOrientation.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func fixPortraitOrientation() -> UIImage {
        guard self.imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
        if let imageWithUpOrientation = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return imageWithUpOrientation
        }
        return self
    }
    
    func fitImageIn(maxSize: CGFloat) -> UIImage {
        let biggestSide: CGFloat = max(self.size.height, self.size.width)
        let scaleFactor: CGFloat = biggestSide / maxSize
        return self.scaledBy(factor: scaleFactor)
    }
    
    func scaledBy(factor scaleFactor: CGFloat) -> UIImage {
        let size = CGSize(width: self.size.width / scaleFactor, height: self.size.height / scaleFactor)
        var scaledImageRect = CGRect.zero
        
        let aspectWidth: CGFloat = size.width / self.size.width
        let aspectHeight: CGFloat = size.height / self.size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: scaledImageRect)
        if let scaledImage = UIGraphicsGetImageFromCurrentImageContext() {
        UIGraphicsEndImageContext()
            return scaledImage
        }
        return self
    }
}
