//
//  SelfieQAError.swift
//  PingOneVerify_iOS
//
//  Created by Bhavya Chauhan on 7/19/22.
//

import Foundation

public enum SelfieQAError: Error, LocalizedError {
    
    case faceLookingUpOrDown
    case faceLookingLeftOrRight
    case faceNotStraight
    case allLandmarksNotInFrame
    case faceTooFar
    case faceTooClose
    case faceNotCentered
    case leftEyeClosed
    case rightEyeClosed
    case mouthOpen
    
    public var errorDescription: String? {
        switch self {
        case .faceLookingUpOrDown,
                .faceLookingLeftOrRight:
            return "idv_face_looking_at_phone".localized
        case .faceNotStraight:
            return "idv_straight_face".localized
        case .allLandmarksNotInFrame,
             .faceTooClose:
            return "idv_hold_camera_further".localized
        case .faceTooFar:
            return "idv_hold_camera_near".localized
        case .faceNotCentered:
            return "idv_center_face".localized
        case .leftEyeClosed,
             .rightEyeClosed:
            return "idv_open_eyes".localized
        case .mouthOpen:
            return "idv_post_capture_close_mouth".localized
        }
    }
}
