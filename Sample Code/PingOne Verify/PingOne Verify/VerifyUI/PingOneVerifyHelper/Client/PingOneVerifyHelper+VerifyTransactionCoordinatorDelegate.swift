//
//  PingOneVerifyHelper+VerifyTransactionCoordinatorDelegate.swift
//  PingOneVerify_iOS
//

import Foundation
import UIKit

// MARK: - VerifyTransactionCoordinatorDelegate

extension PingOneVerifyHelper: VerifyTransactionCoordinatorDelegate {

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            shouldCaptureDocument settings: DocumentCaptureSettings) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.documentCapturePresenter.setProcessing(false, pingOneNavController: self.pingOneNavController)
            self.documentCapturePresenter.captureDocument(
                pingOneNavController: self.pingOneNavController,
                documentCaptureSetting: settings,
                coordinator: coordinator)
        }
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didReceiveLanguagePack languagePackProvider: LanguagePackProviderContract?,
                            error: Error?) {
        guard let languagePackProvider = languagePackProvider else {
            logerror(error?.localizedDescription ?? "Language pack unavailable — continuing without it.")
            fetchConfigGroup.leave()
            return
        }
        VerifyLanguagePackProvider.initializeWith(languagePackProvider: languagePackProvider)
        fetchConfigGroup.leave()
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didReceiveAppTheme appTheme: AppThemeResponse?,
                            error: Error?) {
        if let error = error {
            logerror(error.localizedDescription)
        }
        applyTheme(appTheme ?? AppThemeResponse())
        fetchConfigGroup.leave()
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didCaptureGeolocation latitude: Double,
                            longitude: Double) {
        documentCapturePresenter.setProcessing(true, pingOneNavController: pingOneNavController)
        coordinator.submitGeolocation(latitude: latitude, longitude: longitude)
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            shouldRetryCapture feedback: RetryFeedback,
                            settings: DocumentCaptureSettings) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.documentCapturePresenter.setProcessing(false, pingOneNavController: self.pingOneNavController)
            self.documentCapturePresenter.showRetry(
                pingOneNavController: self.pingOneNavController,
                coordinator: coordinator,
                documentCaptureSetting: settings,
                feedback: feedback)
        }
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didSubmitDocument response: DocumentSubmissionResponse) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard response.documentSubmissionStatus != nil else { return }
            self.documentCapturePresenter.setProcessing(false, pingOneNavController: self.pingOneNavController)
        }
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didSubmitOtp success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let otpVC = self.pingOneNavController.viewControllers.last { $0 is OtpViewController } as? OtpViewController
            otpVC?.handleOtpResult(success)
        }
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didUpdateOtpSession settings: OtpCaptureSettings) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let session = settings.otpSession else { return }
            let otpVC = self.pingOneNavController.viewControllers.last { $0 is OtpViewController } as? OtpViewController
            otpVC?.updateOtpSession(session)
        }
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didCaptureSelfie result: SelfieCaptureResult) {
        self.documentCapturePresenter.showSelfiePreview(
            pingOneNavController: self.pingOneNavController,
            coordinator: coordinator,
            result: result)
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didCaptureGovernmentId result: IdCaptureResult) {
        self.documentCapturePresenter.showIdPreview(
            pingOneNavController: self.pingOneNavController,
            coordinator: coordinator,
            result: result)
    }

    public func coordinator(didCompleteSubmission coordinator: VerifyTransactionCoordinator) {
        documentCapturePresenter.setProcessing(false, pingOneNavController: pingOneNavController)
        guard let rootViewController = rootViewController else { return }
        dismissNavigationController {
            rootViewController.performSegue(withIdentifier: "completed_segue", sender: nil)
        }
    }

    public func coordinator(_ coordinator: VerifyTransactionCoordinator,
                            didFailWith error: DocumentSubmissionError) {
        guard let rootViewController = rootViewController else { return }
        dismissNavigationController {
            let alert = UIAlertController(
                title: "idv_error_title".localized,
                message: error.localizedDescription,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "idv_okay".localized, style: .default))
            rootViewController.present(alert, animated: true)
        }
    }
}
