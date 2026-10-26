//
//  PreviewViewController.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 06/08/24.
//

import UIKit

class PreviewViewController: BaseViewController {
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var readableLabel: UILabel!
    @IBOutlet weak var clearLabel: UILabel!
    @IBOutlet weak var retakeButton: BorderedButton!
    @IBOutlet weak var continueButton: VerifyButton!
    @IBOutlet weak var btnStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    private weak var coordinator: VerifyTransactionCoordinator?
    private var showProcessing: (() -> Void)?
    var captureResult: IdCaptureResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIComponents()
        setUpPreview()
        setUpAccessibilityAnnouncement()
    }

     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpConstraintsForSmallScreenDevices()
    }

     override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    internal class func getViewController(coordinator: VerifyTransactionCoordinator, result: IdCaptureResult, showProcessing: @escaping () -> Void) -> PreviewViewController {
        let bundle: Bundle = Bundle(for: PreviewViewController.self)
        let previewViewController = PreviewViewController(nibName: "PreviewViewController", bundle: bundle)
        previewViewController.coordinator = coordinator
        previewViewController.captureResult = result
        previewViewController.showProcessing = showProcessing
        return previewViewController
    }
    
    func setUpUIComponents() {
        if let clearAttributedString = AttributedStringProvider.shared.fetchAttributedStringFor("idv_data_check_clear") {
            self.clearLabel.attributedText = clearAttributedString
        } else {
            self.clearLabel.text = "idv_data_check_clear".localized
        }
        if let readableAttributedString = AttributedStringProvider.shared.fetchAttributedStringFor("idv_data_check_readable") {
            self.readableLabel.attributedText = readableAttributedString
        } else {
            self.readableLabel.text = "idv_data_check_readable".localized
        }
        self.continueButton.setTitle("idv_data_check_confirm".localized)
        self.retakeButton.setTitle("idv_data_check_retake".localized)
        self.continueButton.layer.cornerRadius = DataCaptureConstants.BUTTON_CORNER_RADIUS
        self.continueButton.titleLabel?.font = .systemFont(ofSize: DataCaptureConstants.BUTTON_FONT_SIZE)
        self.retakeButton.layer.cornerRadius = DataCaptureConstants.BUTTON_CORNER_RADIUS
        self.retakeButton.layer.borderWidth = DataCaptureConstants.SKIP_BUTTON_BORDER_WIDTH
        self.retakeButton.titleLabel?.font = .systemFont(ofSize: DataCaptureConstants.BUTTON_FONT_SIZE)
        self.retakeButton.layer.borderColor = AppthemeHandler.borderedButtonBorderColor.cgColor
        self.retakeButton.titleLabel?.textColor = AppthemeHandler.borderedButtonTextColor
    }
    
    /// VoiceOver: tell the user the scan succeeded and what this screen is (NEO-6568). An invisible
    /// 1x1 element carries the localizable text (overridable via the remote language pack) and is
    /// the screen's accessibility header, so BaseViewController moves the VoiceOver cursor to it
    /// on arrival — ahead of the nav-bar back button.
    private func setUpAccessibilityAnnouncement() {
        let announcementElement = UIView()
        announcementElement.translatesAutoresizingMaskIntoConstraints = false
        announcementElement.backgroundColor = .clear
        announcementElement.isAccessibilityElement = true
        announcementElement.accessibilityLabel = "idv_id_review_announcement".localized
        announcementElement.accessibilityTraits = [.staticText, .header]
        view.addSubview(announcementElement)
        NSLayoutConstraint.activate([
            announcementElement.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            announcementElement.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            announcementElement.widthAnchor.constraint(equalToConstant: 1),
            announcementElement.heightAnchor.constraint(equalToConstant: 1)
        ])
        accessibilityHeaderElement = announcementElement
        alwaysPostHeaderFocus = true
    }

    func setUpPreview() {
        if let data = captureResult?.documentData {
            if let frontImage = data["frontImage"] {
                self.frontImage.image = frontImage.toImage()
            } else {
                self.frontImage.isHidden = true
            }
            if let backImage = data["backImage"] {
                self.backImage.image = backImage.toImage()
            } else {
                self.backImage.isHidden = true
            }
        }
        self.maskImageForVoiceOver(self.frontImage, label: "idv_id_front_image_label".localized)
        self.maskImageForVoiceOver(self.backImage, label: "idv_id_back_image_label".localized)
    }

    /// VoiceOver: the ID images contain PII, and VoiceOver's image recognition can read the text
    /// in an image element aloud. Hide the picture from VoiceOver and expose a plain text-labelled
    /// element over it instead, so only the label ("Front ID Image") is announced.
    private func maskImageForVoiceOver(_ imageView: UIImageView, label: String) {
        imageView.isAccessibilityElement = false
        let labelElement = UIView()
        labelElement.translatesAutoresizingMaskIntoConstraints = false
        labelElement.backgroundColor = .clear
        labelElement.isAccessibilityElement = true
        labelElement.accessibilityLabel = label
        labelElement.accessibilityTraits = .staticText
        imageView.addSubview(labelElement)
        NSLayoutConstraint.activate([
            labelElement.topAnchor.constraint(equalTo: imageView.topAnchor),
            labelElement.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            labelElement.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            labelElement.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        handleContinueFlow()
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any) {
        if let nav = navigationController { self.coordinator?.captureGovernmentId(from: nav) }
    }

    func handleContinueFlow() {
        if let result = captureResult {
            showProcessing?()
            coordinator?.submitGovernmentId(result)
        }
    }
}

extension PreviewViewController {
    func navigateToDocumentSelection() {
        let documentSelectionVc = DocumentSelectionViewController.getViewController(delegate: self)
        self.navigationController?.pushViewController(documentSelectionVc, animated: true)
    }
}
 
extension PreviewViewController: DocumentCallBack {
    func didSelectDocument(_ document: DocumentModel) {
        let _ = document.getDocumentType()
    }
}

extension PreviewViewController {
    func setUpConstraintsForSmallScreenDevices() {
        // Use 'guard let' to safely unwrap all outlets at once
        guard let frontImage = frontImage,
              let backImage = backImage,
              let btnStackViewTopConstraint = btnStackViewTopConstraint,
              let imageStackViewTopConstraint = imageStackViewTopConstraint,
              let titleLabelTopConstraint = titleLabelTopConstraint else { return }
        if isSmallScreenDevice() {
            if !frontImage.isHidden, !backImage.isHidden {
                btnStackViewTopConstraint.constant = 16
                imageStackViewTopConstraint.constant = 28
                titleLabelTopConstraint.constant = 10
            }
        } else {
            btnStackViewTopConstraint.isActive = false
        }
    }
    
    func isSmallScreenDevice() -> Bool {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return screenHeight <= DataCaptureConstants.SMALLER_DEVICES
    }
}
