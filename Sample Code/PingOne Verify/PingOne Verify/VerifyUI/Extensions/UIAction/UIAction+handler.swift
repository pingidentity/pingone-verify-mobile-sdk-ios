//
//  UIAction+Handler.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/25/22.
//

import Foundation
import UIKit

extension UIAction {
    var handler: UIActionHandler? {
        get {
            typealias ActionHandlerBlock = @convention(block) (UIAction) -> Void
            let handler = value(forKey: "handler") as? AnyObject
            return unsafeBitCast(handler, to: ActionHandlerBlock.self)
        }
    }
}
