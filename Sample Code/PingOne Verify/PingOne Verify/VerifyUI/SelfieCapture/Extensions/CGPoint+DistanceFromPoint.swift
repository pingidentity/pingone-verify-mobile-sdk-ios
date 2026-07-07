//
//  CGPoint+DistanceFromPoint.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/31/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    
    func distanceFrom(point: CGPoint) -> CGFloat {
        return hypot(point.x - self.x, point.y - self.y)
    }
    
}
