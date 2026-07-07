//
//  CameraOverlayView.swift
//  SCMRZScanner
//
//  Created by Bhavya Chauhan on 5/12/17.
//  Copyright © 2017 ShoCard Inc. All rights reserved.
//

import Foundation
import UIKit

public class CameraOverlayView: UIView {
    
    public var previewRectFrame: CGRect?
    public var overlayBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    public var drawOutline: Bool = true//false
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let previewRectFrame = self.previewRectFrame else {
            return
        }
        
        
        self.backgroundColor = self.overlayBackgroundColor
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.fillColor = self.overlayBackgroundColor.cgColor
        
        let path = UIBezierPath(rect: self.bounds)
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        path.append(UIBezierPath(roundedRect: previewRectFrame, cornerRadius: 7))
        
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        if (drawOutline) {
            let viewBorderLayer = CAShapeLayer()
            viewBorderLayer.frame = previewRectFrame
            viewBorderLayer.bounds = previewRectFrame
            viewBorderLayer.strokeColor = UIColor.white.cgColor
            viewBorderLayer.fillColor = nil
            viewBorderLayer.lineWidth = 7
                        
            let topLeft = CGPoint(x: previewRectFrame.origin.x, y: previewRectFrame.origin.y)
            let topRight = CGPoint(x: previewRectFrame.origin.x + previewRectFrame.width, y: previewRectFrame.origin.y)
            let bottomRight = CGPoint(x: previewRectFrame.origin.x + previewRectFrame.width, y: previewRectFrame.origin.y + previewRectFrame.height)
            let bottomLeft = CGPoint(x: previewRectFrame.origin.x, y: previewRectFrame.origin.y + previewRectFrame.height)
            
            let lineSize = 0.6 * previewRectFrame.height
            let curveTransformFactor: CGFloat = 7.0
            let transformFactor: CGFloat = (previewRectFrame.height - lineSize) / 2
            
            let borderPath = UIBezierPath() //UIBezierPath(roundedRect: previewRectFrame, cornerRadius: 7)
            borderPath.move(to: topLeft.applying(CGAffineTransform(translationX: 0, y: transformFactor)))
            borderPath.addLine(to: topLeft.applying(CGAffineTransform(translationX: 0, y: curveTransformFactor)))
            borderPath.addQuadCurve(to: topLeft.applying(CGAffineTransform(translationX: curveTransformFactor, y: 0)), controlPoint: topLeft)
            borderPath.addLine(to: topLeft.applying(CGAffineTransform(translationX: transformFactor, y: 0)))
            
            borderPath.move(to: topRight.applying(CGAffineTransform(translationX: -transformFactor, y: 0)))
            borderPath.addLine(to: topRight.applying(CGAffineTransform(translationX: -curveTransformFactor, y: 0)))
            borderPath.addQuadCurve(to: topRight.applying(CGAffineTransform(translationX: 0, y: curveTransformFactor)), controlPoint: topRight)
            borderPath.addLine(to: topRight.applying(CGAffineTransform(translationX: 0, y: transformFactor)))
            
            
            borderPath.move(to: bottomRight.applying(CGAffineTransform(translationX: 0, y: -transformFactor)))
            borderPath.addLine(to: bottomRight.applying(CGAffineTransform(translationX: 0, y: -curveTransformFactor)))
            borderPath.addQuadCurve(to: bottomRight.applying(CGAffineTransform(translationX: -curveTransformFactor, y: 0)), controlPoint: bottomRight)
            borderPath.addLine(to: bottomRight.applying(CGAffineTransform(translationX: -transformFactor, y: 0)))
            
            borderPath.move(to: bottomLeft.applying(CGAffineTransform(translationX: transformFactor, y: 0)))
            borderPath.addLine(to: bottomLeft.applying(CGAffineTransform(translationX: curveTransformFactor, y: 0)))
            borderPath.addQuadCurve(to: bottomLeft.applying(CGAffineTransform(translationX: 0, y: -curveTransformFactor)), controlPoint: bottomLeft)
            borderPath.addLine(to: bottomLeft.applying(CGAffineTransform(translationX: 0, y: -transformFactor)))

            viewBorderLayer.path = borderPath.cgPath
            
            self.layer.addSublayer(viewBorderLayer)
        }
        
    }
        
}
