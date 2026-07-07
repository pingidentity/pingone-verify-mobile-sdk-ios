//
//  DocumentCaptureViewController.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 5/4/22.
//

import UIKit

class DocumentCaptureViewController: BaseViewController {
    
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var startButton: VerifyButton!
    @IBOutlet weak var imageView: IconImageView!
    @IBOutlet weak var skipButton: BorderedButton!
    
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    var coordinator: VerifyTransactionCoordinator?

    internal class func getViewController(documentCaptureSettings: DocumentCaptureSettings, coordinator: VerifyTransactionCoordinator) -> DocumentCaptureViewController {
        let bundle: Bundle = Bundle(for: DocumentCaptureViewController.self)
        let documentCaptureViewController = DocumentCaptureViewController(nibName: "DocumentCaptureViewController", bundle: bundle)
        documentCaptureViewController.documentCaptureSettings = documentCaptureSettings
        documentCaptureViewController.documentType = documentCaptureSettings.documentType
        documentCaptureViewController.coordinator = coordinator
        return documentCaptureViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpConstraintsForSmallScreenDevices()
        
        self.updateImage(with: IconImageView.appearance().tintColor)
        
        if self.documentType == .SELFIE && documentCaptureSettings?.isAuthflow == true {
            self.startCapture()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let documentCaptureSettings = self.documentCaptureSettings, documentCaptureSettings.isRetry {
            documentCaptureSettings.isRetry = false
            self.startCapture()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpUIComponents()
        self.setLabelDescriptions()
    }
    
    func setUpUIComponents() {
        self.startButton.setTitle("idv_next".localized)
        self.skipButton.setTitle("idv_skip".localized)
        if let optional = self.documentCaptureSettings?.optional {
            self.skipButton.isHidden = !optional
            self.skipButton.isEnabled = optional
        }
    }
    
    func setUpConstraintsForSmallScreenDevices(){
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        guard let imageTopConstraint = imageTopConstraint,
              let textViewBottomConstraint = textViewBottomConstraint else { return }
        if screenHeight <= DataCaptureConstants.SMALLER_DEVICES {
            imageTopConstraint.constant = 40
            textViewBottomConstraint.constant = 10
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        if self.documentType == .GOVERNMENT_ID {
            self.documentType = .PASSPORT
        }
        coordinator?.skipDocument(type: self.documentType)
    }
    
    internal func setDocumentCaptureSettings(documentCaptureSettings: DocumentCaptureSettings) {
        self.documentCaptureSettings = documentCaptureSettings
    }
    
    private func updateImage(with color: UIColor?) {
        if let tintColor = color {
            self.imageView.image = UIImage.loadImage(named: self.documentType.iconName)?.withTintColor(tintColor).withRenderingMode(.alwaysOriginal)
        } else {
            self.imageView.image = UIImage.loadImage(named: self.documentType.iconName)
        }
    }
    
    internal func setLabelDescriptions() {
        
        if let documentCaptureHeaderAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_documentCapture_header_\(self.documentType.rawValue)") {
            self.headerTextLabel.attributedText = documentCaptureHeaderAttributedText
        } else {
            self.headerTextLabel.text = "idv_documentCapture_header_\(self.documentType.rawValue)".localized
        }

        if let documentCaptureDescAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_documentCapture_description_\(self.documentType.rawValue)") {
            self.bodyTextView.attributedText = documentCaptureDescAttributedText as! NSMutableAttributedString
        } else {
            self.bodyTextView.text = "idv_documentCapture_description_\(self.documentType.rawValue)".localized
        }
        
        let fixedWidth = self.bodyTextView.frame.size.width
        let newSize = self.bodyTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textViewHeightConstraint.constant = newSize.height
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedClicks()
        self.startCapture()
    }
    
    func startCapture() {
        if self.isCameraGranted() {
            if self.documentType == .SELFIE {
                if let nav = self.navigationController { self.coordinator?.captureSelfie(from: nav) }
            } else if self.documentType.isGovernmentIdClass {
                if let nav = self.navigationController { self.coordinator?.captureGovernmentId(from: nav) }
            } else {
                CustomToastView.display(isError: true, text: DocumentCaptureError.initError("Cannot start capture").localizedDescription ?? "")
            }
        } else {
            self.requestCameraPermission(dismiss: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppEventManager.shared.flushAppEvents()
        
        if isMovingFromParent {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PingOneVerifyNotification.BACK_BUTTON_PRESSED_NOTIFICATION_CENTER_KEY), object: self, userInfo: ["documentType": self.documentType as Any])
        }
    }
    
}

