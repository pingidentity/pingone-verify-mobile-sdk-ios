//
//  SCFace.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 4/29/20.
//  Copyright © 2020 com.shocard. All rights reserved.
//

import Foundation
import UIKit

public class SCFace {
    
    internal let faceId: Int
    internal let boundingBox: CGRect
    internal let hasSmile: Bool
    internal let isLeftEyeClosed: Bool
    internal let isRightEyeClosed: Bool
    internal let headTiltAngle: Float
    
    internal var originalImageSize: CGRect?
    internal var underlyingObject: Any?
    
    internal init(faceId: Int, boundingBox: CGRect, hasSmile: Bool, isLeftEyeClosed: Bool, isRightEyeClosed: Bool, headTiltAngle: Float) {
        self.faceId = faceId
        self.boundingBox = boundingBox
        self.hasSmile = hasSmile
        self.isLeftEyeClosed = isLeftEyeClosed
        self.isRightEyeClosed = isRightEyeClosed
        self.headTiltAngle = headTiltAngle
    }
    
    
}
