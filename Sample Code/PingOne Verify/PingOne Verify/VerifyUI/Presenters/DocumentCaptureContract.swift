//
//  DocumentCaptureContract.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/31/22.
//

import Foundation
import UIKit

public protocol DocumentCaptureContract {
    func captureDocument(pingOneNavController: UINavigationController, documentCaptureSetting: DocumentCaptureSettings, coordinator: VerifyTransactionCoordinator)
    func showRetry(pingOneNavController: UINavigationController, coordinator: VerifyTransactionCoordinator, documentCaptureSetting: DocumentCaptureSettings, feedback: RetryFeedback)
    func setProcessing(_ isProcessing: Bool, pingOneNavController: UINavigationController)
    func showSelfiePreview(pingOneNavController: UINavigationController, coordinator: VerifyTransactionCoordinator, result: SelfieCaptureResult)
    func showIdPreview(pingOneNavController: UINavigationController, coordinator: VerifyTransactionCoordinator, result: IdCaptureResult)
}
