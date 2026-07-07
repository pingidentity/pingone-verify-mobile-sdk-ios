//
//  UITextField+addLeftView.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/30/23.
//

import Foundation
import UIKit

extension UITextField {
    func addLeftView() {
        let viewRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 6, height: DataCaptureConstants.TEXT_FIELD_HEIGHT))
        let verticalLeftView = UIView(frame: viewRect)
        verticalLeftView.clipsToBounds = true
        verticalLeftView.layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
        verticalLeftView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        verticalLeftView.backgroundColor = AppthemeHandler.buttonColor
        self.addSubview(verticalLeftView)
    }
}
