//
//  OvalCameraOverlayView.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/23/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class OvalCameraOverlayView: UIView {
    
    public var previewRectFrame: CGRect?
    public var overlayBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
    public var drawOutline: Bool = true
    private var outlineColor: UIColor = UIColor.clear
    
    private lazy var viewBorderLayer: CAShapeLayer = {
        let viewBorderLayer = CAShapeLayer()
        viewBorderLayer.fillColor = nil
        viewBorderLayer.lineWidth = 5
        
        return viewBorderLayer
    }()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let previewRectFrame = self.previewRectFrame else {
            return
        }
        
        let viewLayer = CAShapeLayer()
        viewLayer.frame = self.bounds
        viewLayer.backgroundColor = self.overlayBackgroundColor.cgColor
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.fillColor = self.overlayBackgroundColor.cgColor
        
        let path = UIBezierPath(rect: self.bounds)
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        let viewPortPath = UIBezierPath(ovalIn: previewRectFrame).reversing()
        path.append(viewPortPath)
        
        maskLayer.path = path.cgPath
        viewLayer.mask = maskLayer
        self.layer.addSublayer(viewLayer)
        
        if (self.drawOutline) {
            self.viewBorderLayer.frame = previewRectFrame
            self.viewBorderLayer.bounds = previewRectFrame
            self.viewBorderLayer.path = viewPortPath.cgPath
            
            self.layer.addSublayer(self.viewBorderLayer)
            self.updateOutlineColor(self.outlineColor)
        }
        
    }
    
    public func updateOutlineColor(_ newColor: UIColor) {
        DispatchQueue.main.async {
            guard self.outlineColor != newColor else {
                return
            }
            let oldColor = self.outlineColor
            self.outlineColor = newColor
            self.viewBorderLayer.strokeColor = self.outlineColor.cgColor
            
            let colorAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeColor))
            colorAnimation.fromValue = oldColor.cgColor
            colorAnimation.toValue = newColor.cgColor
            colorAnimation.duration = 0.3
            colorAnimation.fillMode = .forwards
            
            CATransaction.begin()
            self.viewBorderLayer.add(colorAnimation, forKey: #keyPath(CAShapeLayer.strokeColor))
            CATransaction.commit()
        }
    }
    
}
