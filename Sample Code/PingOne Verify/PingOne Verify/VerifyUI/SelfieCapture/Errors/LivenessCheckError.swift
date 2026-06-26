//
//  LivenessCheckError.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 9/9/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation

public enum LivenessCheckError: Error, LocalizedError {
    
    case cannotInitFaceDetector
    case invalidObjectInResult
    case noFaceFound
    case differentFaceFound
    case multipleFacesFound
    case faceMovedOutOfFrame
 
    case cannotGetCIImage
    case invalidSampleBuffer
    
    case cannotCaptureImage
    
    public var errorDescription: String? {
        switch self {
        case .cannotInitFaceDetector:
            return "idv_cannotInitFaceDetector".localized
        case .invalidObjectInResult:
            return "idv_invalidObjectInResult".localized
        case .noFaceFound:
            return "idv_noFaceFound".localized
        case .differentFaceFound:
            return "idv_differentFaceFound".localized
        case .multipleFacesFound:
            return "idv_multipleFacesFound".localized
        case .faceMovedOutOfFrame:
            return "idv_faceMovedOutOfFrame".localized
        case .cannotGetCIImage:
            return "idv_cannotGetCIImage".localized
        case .invalidSampleBuffer:
            return "idv_invalidSampleBuffer".localized
        case .cannotCaptureImage:
            return "idv_cannotCaptureImage".localized
        }
    }
    
}

public enum CameraError: Error, LocalizedError {

    case cannotSetFocusMode(_ reason: Error)
    case cannotGetCamera
    case cannotInitializeInputForCamera(_ reason: Error)
    case cannotAddOutputsToCamera

    public var errorDescription: String? {
        switch self {
        case .cannotSetFocusMode(let reason):
            print("Cannot set focus mode: Internal reason: \(reason.localizedDescription)")
            return "cannotSetFocusMode".localized(in: "SelfieCapture")
        case .cannotInitializeInputForCamera(let reason):
            print("Cannot initialize input for camera: Internal reason: \(reason.localizedDescription)")
            return "cannotInitializeInputForCamera".localized(in: "SelfieCapture")
        case .cannotAddOutputsToCamera:
            return "cannotAddOutputsToCamera".localized(in: "SelfieCapture")
        case .cannotGetCamera:
            return "cannotGetCamera".localized(in: "SelfieCapture")
        }
    }
}

public enum IdCaptureError: Error, LocalizedError {
    case cannotCaptureId

    public var errorDescription: String? {
        switch self {
        case .cannotCaptureId:
            return "mb_recognition_timeout_dialog_message".localized
        }
    }
    
}
