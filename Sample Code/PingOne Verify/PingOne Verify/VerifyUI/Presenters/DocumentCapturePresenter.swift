//
//  DocumentCapturePresenter.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 4/4/22.
//

import Foundation
import UIKit

internal class DocumentCapturePresenter: DocumentCaptureContract {

    func setProcessing(_ isProcessing: Bool, pingOneNavController: UINavigationController) {
        DispatchQueue.main.async {
            if isProcessing {
                let processingViewController = ProcessingViewController.getViewController()
                pingOneNavController.pushViewController(processingViewController, animated: false)
            } else {
                pingOneNavController.viewControllers.removeAll { $0 is ProcessingViewController }
            }
        }
    }

    func showRetry(pingOneNavController: UINavigationController, coordinator: VerifyTransactionCoordinator, documentCaptureSetting: DocumentCaptureSettings, feedback: RetryFeedback) {
        DispatchQueue.main.async {
            let retryViewController = RetryViewController.getViewController(coordinator: coordinator, documentCaptureSettings: documentCaptureSetting, feedback: feedback)
            pingOneNavController.pushViewController(retryViewController, animated: true)
        }
    }

    func captureDocument(pingOneNavController: UINavigationController, documentCaptureSetting: DocumentCaptureSettings, coordinator: VerifyTransactionCoordinator) {
        DispatchQueue.main.async { [weak pingOneNavController] in
            guard let pingOneNavController = pingOneNavController else { return }
            let showProcessing = { [weak pingOneNavController] in
                guard let nav = pingOneNavController else { return }
                nav.pushViewController(ProcessingViewController.getViewController(), animated: false)
            }
            switch documentCaptureSetting.documentType {
            case .EMAIL:
                if let otpSettings = documentCaptureSetting as? OtpCaptureSettings, otpSettings.otpSession != nil {
                    if let otpViewController = OtpViewController.getViewController(coordinator: coordinator, documentCaptureSetting: otpSettings) {
                        otpViewController.showProcessing = showProcessing
                        pingOneNavController.pushViewController(otpViewController, animated: false)
                    } else {
                        CustomToastView.display(isError: true, text: DocumentCaptureError.otpInformationMissing.localizedDescription ?? "")
                    }
                } else {
                    let emailCaptureViewController = EmailCaptureViewController.getViewController(coordinator: coordinator, documentCaptureSettings: documentCaptureSetting, documentType: documentCaptureSetting.documentType)
                    emailCaptureViewController.showProcessing = showProcessing
                    pingOneNavController.pushViewController(emailCaptureViewController, animated: true)
                }
            case .PHONE:
                if let otpSettings = documentCaptureSetting as? OtpCaptureSettings, otpSettings.otpSession != nil {
                    if let otpViewController = OtpViewController.getViewController(coordinator: coordinator, documentCaptureSetting: otpSettings) {
                        otpViewController.showProcessing = showProcessing
                        pingOneNavController.pushViewController(otpViewController, animated: false)
                    } else {
                        CustomToastView.display(isError: true, text: DocumentCaptureError.otpInformationMissing.localizedDescription ?? "")
                    }
                } else {
                    let phoneCaptureViewController = PhoneCaptureViewController.getViewController(coordinator: coordinator, documentCaptureSettings: documentCaptureSetting, documentType: documentCaptureSetting.documentType)
                    phoneCaptureViewController.showProcessing = showProcessing
                    pingOneNavController.pushViewController(phoneCaptureViewController, animated: true)
                }
            case .GEOLOCATION:
                let geolocationPermissionViewController = GeolocationPermissionViewController.getViewController(coordinator: coordinator)
                pingOneNavController.pushViewController(geolocationPermissionViewController, animated: true)
            default:
                let documentCaptureViewController = DocumentCaptureViewController.getViewController(documentCaptureSettings: documentCaptureSetting, coordinator: coordinator)
                let isAnimated = documentCaptureSetting.isRetry ? false : true
                pingOneNavController.pushViewController(documentCaptureViewController, animated: isAnimated)
            }
        }
    }

    func showSelfiePreview(pingOneNavController: UINavigationController, coordinator: VerifyTransactionCoordinator, result: SelfieCaptureResult) {
        DispatchQueue.main.async { [weak pingOneNavController] in
            guard let pingOneNavController = pingOneNavController else { return }
            let showProcessing = { [weak pingOneNavController] in
                guard let nav = pingOneNavController else { return }
                nav.pushViewController(ProcessingViewController.getViewController(), animated: false)
            }
            let vc = SelfiePreviewViewController.getViewController(result: result, coordinator: coordinator, showProcessing: showProcessing)
            pingOneNavController.pushViewController(vc, animated: true)
        }
    }

    func showIdPreview(pingOneNavController: UINavigationController, coordinator: VerifyTransactionCoordinator, result: IdCaptureResult) {
        DispatchQueue.main.async { [weak pingOneNavController] in
            guard let pingOneNavController = pingOneNavController else { return }
            let showProcessing = { [weak pingOneNavController] in
                guard let nav = pingOneNavController else { return }
                nav.pushViewController(ProcessingViewController.getViewController(), animated: false)
            }
            let vc = PreviewViewController.getViewController(coordinator: coordinator, result: result, showProcessing: showProcessing)
            pingOneNavController.pushViewController(vc, animated: true)
        }
    }
}
