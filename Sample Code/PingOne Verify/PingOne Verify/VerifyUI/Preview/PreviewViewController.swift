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
