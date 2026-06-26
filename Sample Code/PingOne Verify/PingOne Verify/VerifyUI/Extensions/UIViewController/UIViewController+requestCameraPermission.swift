//
//  UIViewController+requestCameraPermission.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 9/20/22.
//

import Foundation
import UIKit

extension UIViewController {
   internal func requestCameraPermission(dismiss: Bool) {
        SCAVCaptureWrapper.requestCameraPermission { (granted) in
            DispatchQueue.main.async {
                if (granted) {
                    let cameraPermissionAppEvent = AppEvent(key: AppEventConstants.CAMERA_PERMISSION_GRANTED, value: AppConstants.eventValueTrue)
                    AppEventStorage.shared.addAppEvents(events: cameraPermissionAppEvent, eventType: .CAMERA)
                } else {
                    let errorAppEvent = AppEvent(key: AppEventConstants.ERROR_CAMERA_PERMISSION_NOT_GRANTED, value: AppConstants.eventValueTrue)
                    AppEventStorage.shared.addAppEvents(events: errorAppEvent, eventType: .ERRORS)
                    
                    SCAVCaptureWrapper.showCameraPermissionRationale(parentViewController: self, message: "idv_camera_permission_rationale".localized, onCanceled: {
                        if dismiss {
                            self.dismiss(animated: true)
                        }
                    })
                }
            }
        }
    }
    
    internal func isCameraGranted() -> Bool {
        return SCAVCaptureWrapper.isCameraPermissionGranted()
    }
}
