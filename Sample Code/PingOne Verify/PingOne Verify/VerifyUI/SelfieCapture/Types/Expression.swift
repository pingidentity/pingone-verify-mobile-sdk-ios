//
//  Expression.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 9/9/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation

public struct ExpressionPair {

    public let expression: Expression
    public let oppositeExpression: Expression

}

public enum Expression {
    
    case smile
    case eyeBlink
    case noSmile
    case openEyes

    public func getStepLabel() -> String {
        switch self {
        case .smile:
            return "idv_smile".localized
        case .noSmile:
            return "idv_no_smile".localized
        case .eyeBlink:
            return "idv_blink_eyes".localized
        case .openEyes:
            return "idv_open_eyes".localized
        }
    }
    
    public func getFrameThreshold() -> Int {
        switch self {
        case .eyeBlink, .openEyes:
            return 5
        case .smile, .noSmile:
            return 10
        }
    }
    
    
}
