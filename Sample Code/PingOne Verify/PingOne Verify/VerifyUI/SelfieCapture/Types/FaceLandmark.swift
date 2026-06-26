//
//  FaceLandmark.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/31/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import Vision
import AVFoundation
import UIKit

public struct FaceLandmark {

    public let type: LandmarkType
    public let landmark: VNFaceLandmarkRegion2D
    public let closePath: Bool

    public init?(landmark: VNFaceLandmarkRegion2D?, type: LandmarkType, closePath: Bool = true) {
        guard let faceLandmark = landmark else {
            return nil
        }
        
        self.landmark = faceLandmark
        self.type = type
        self.closePath = closePath
    }
    
    public func getPath(in faceBox: CGRect) -> CGMutablePath {
        let landmarkPath = CGMutablePath()
        let landmarkPathPoints = self.landmark.normalizedPoints.map {
            CGPoint(x: $0.y * faceBox.height + faceBox.origin.x, y: $0.x * faceBox.width + faceBox.origin.y)
        }
        landmarkPath.addLines(between: landmarkPathPoints)
        
        if (self.closePath) {
            landmarkPath.closeSubpath()
        }
        
        return landmarkPath
    }
    
    public func getLayer(in faceBox: CGRect, strokeColor: UIColor = UIColor.green, lineWidth: CGFloat = 1.0, scaleBy: CGFloat? = nil) -> CAShapeLayer {
        let landmarkLayer = CAShapeLayer()
        landmarkLayer.path = scaleBy == nil ? self.getPath(in: faceBox) : self.getScaledPath(scaleBy!, in: faceBox)
        landmarkLayer.fillColor = UIColor.clear.cgColor
        landmarkLayer.strokeColor = strokeColor.cgColor
        landmarkLayer.lineWidth = lineWidth
        landmarkLayer.lineDashPattern = [5, 3, 4, 4]
        
        return landmarkLayer
    }
    
    private func getScaledPath(_ scaleFactor: CGFloat, in faceBox: CGRect) -> CGPath {
        let path = self.getPath(in: faceBox)
        let originalBox = path.boundingBox
        let scaledBox = originalBox.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        let xCenterOffset: CGFloat = (originalBox.width - scaledBox.width) / 2.0
        let yCenterOffset: CGFloat = (originalBox.height - scaledBox.height) / 2.0
        let xOffset = (originalBox.origin.x - scaledBox.origin.x) + xCenterOffset
        let yOffset = (originalBox.origin.y - scaledBox.origin.y) + yCenterOffset
        
        var transform = CGAffineTransform(translationX: xOffset, y: yOffset).scaledBy(x: scaleFactor, y: scaleFactor)
        return path.copy(using: &transform) ?? path
    }
    
}
