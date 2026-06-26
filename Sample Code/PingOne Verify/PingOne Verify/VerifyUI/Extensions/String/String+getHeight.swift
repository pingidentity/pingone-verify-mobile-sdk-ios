//
//  String+getHeight.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/30/23.
//

import Foundation
import UIKit

extension String {
    func getHeight(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }
}
