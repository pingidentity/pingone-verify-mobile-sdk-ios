//
//  RetryViewController.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 25/06/24.
//

import UIKit

class RetryViewController: BaseViewController {
    @IBOutlet weak var retryButton: VerifyButton!
    @IBOutlet weak var cancelButton: BorderedButton!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var headerLabel: HeaderLabel!
    @IBOutlet weak var iconImageView: IconImageView!
    @IBOutlet weak var closeButton: UIButton!
    var retryFeedback: RetryFeedback?
    
    var coordinator: VerifyTransactionCoordinator?
    var isOptional = false

    internal class func getViewController(coordinator: VerifyTransactionCoordinator, documentCaptureSettings: DocumentCaptureSettings, feedback: RetryFeedback) -> RetryViewController {
        let bundle: Bundle = Bundle(for: RetryViewController.self)
        let retryViewController = RetryViewController(nibName: "RetryViewController", bundle: bundle)
        retryViewController.coordinator = coordinator
        retryViewController.documentCaptureSettings = documentCaptureSettings
        retryViewController.documentType = documentCaptureSettings.documentType
        retryViewController.isOptional = documentCaptureSettings.optional
        retryViewController.retryFeedback = feedback
        return retryViewController
    }
    
    override func viewDidLoad() {
        DocumentSubmissionTimer.VERTICAL_CONSTANT = 30
        super.viewDidLoad()
        self.setUpUIComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DocumentSubmissionTimer.VERTICAL_CONSTANT = 10
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setUpUIComponents() {
        iconImageView.image = UIImage.loadImage(named: "retry")
        var closeConfig = closeButton.configuration
        closeConfig?.image = UIImage.loadImage(named: "idv_cancel")?.withRenderingMode(.alwaysOriginal)
        closeButton.configuration = closeConfig
        self.retryButton.setTitle("idv_retry".localized, for: .normal)
        self.cancelButton.setTitle("idv_cancel".localized, for: .normal)
        //NEO-5326: Cancel button is hidden in retry as per design
        self.cancelButton.isHidden = true

        if documentType == .NFC {
            headerLabel.text = "idv_nfc_retry_title".localized
            // The session-expiry countdown is not meaningful on the NFC retry screen — hide it.
            self.timerLabel?.isHidden = true
        } else if let headerAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_retry") {
            self.headerLabel.attributedText = headerAttributedText
        } else {
            self.headerLabel.text = "idv_retry".localized
        }
        if let feedback = retryFeedback {
            reasonLabel.text = documentType == .NFC ? "idv_nfc_retry_message".localized : (feedback.languagePackKey ?? feedback.message).localized
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        // For NFC, core's observer reports the cancelled attempt to the backend (instead of
        // ending the transaction) and PingOneVerifyHelper's abandonment observer skips it —
        // see the `documentType == .NFC` checks on both observers of this notification.
        NotificationCenter.default.post(name: Notification.Name(rawValue: PingOneVerifyNotification.CANCELED_NOTIFICATION_CENTER_KEY), object: documentType, userInfo: [:])
    }

    @IBAction func retryButtonTapped(_ sender: Any) {
        retryButton.preventRepeatedClicks()
        guard let nav = self.navigationController else { return }
        guard let documentCaptureSettings else { return }
        if documentType == .SELFIE {
            coordinator?.captureSelfie(from: nav, settings: documentCaptureSettings)
        } else if documentType == .NFC {
            // captureNfc expects the presenting view controller (not the nav itself) and
            // derives the navigation controller from it.
            coordinator?.captureNfc(from: self, settings: documentCaptureSettings)
        } else if documentType.isGovernmentIdClass {
            coordinator?.captureGovernmentId(from: nav, settings: documentCaptureSettings)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if self.documentType == .GOVERNMENT_ID {
            self.documentType = .PASSPORT
        }
        coordinator?.skipDocument(type: self.documentType)
    }
}

