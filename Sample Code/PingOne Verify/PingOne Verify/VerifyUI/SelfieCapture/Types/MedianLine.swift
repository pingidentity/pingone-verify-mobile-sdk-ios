//
//  MedianLine.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/31/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import Vision

public struct MedianLine {

    public let startPoint: CGPoint
    public let endPoint: CGPoint
    public let angle: Double

    public init(medianLandmark: VNFaceLandmarkRegion2D, in faceBox: CGRect) {
        let medianPoints = medianLandmark.normalizedPoints.map {
            CGPoint(x: $0.y * faceBox.height + faceBox.origin.x, y: $0.x * faceBox.width + faceBox.origin.y)
        }
        let startPoint = medianPoints[0]
        let endPoint = medianPoints[medianPoints.count - 1]
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        
        let radians = atan2(dx, dy)
        let angle = Double(radians) * 180 / Double.pi
        self.init(startPoint: startPoint, endPoint: endPoint, angle: angle)
    }
    
    public init(startPoint: CGPoint, endPoint: CGPoint, angle: Double) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.angle = angle
    }
    
}
