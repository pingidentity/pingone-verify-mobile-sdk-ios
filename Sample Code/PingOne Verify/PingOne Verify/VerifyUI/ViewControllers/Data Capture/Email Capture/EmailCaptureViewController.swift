//
//  EmailCaptureViewController.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 4/14/23.
//

import UIKit

class EmailCaptureViewController: DataCaptureViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    internal override class func getViewController(coordinator: VerifyTransactionCoordinator, documentCaptureSettings: DocumentCaptureSettings, documentType: DocumentClass) -> EmailCaptureViewController {
        let bundle: Bundle = Bundle(for: EmailCaptureViewController.self)
        let emailCaptureViewController = EmailCaptureViewController(nibName: "DataCaptureViewController", bundle: bundle)
        emailCaptureViewController.coordinator = coordinator
        emailCaptureViewController.documentCaptureSettings = documentCaptureSettings
        emailCaptureViewController.documentType = documentType

        return emailCaptureViewController
    }
    
    override func sendOtpButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedClicks()
        if let emailTextField = self.dataTextField {
            emailTextField.resignFirstResponder()
        }
        if (self.documentCaptureSettings as? OtpCaptureSettings)?.requirements?.requirementsValue == nil {
            guard let text = self.dataTextField.text else { return }
            
            self.data = text
        }

        DataCaptureViewController.lastEnteredDestination = self.data
        showProcessing?()
        coordinator?.submitEmail(self.data)
    }
    
    override func showDataTextField() {
        self.addObserver()
        
        self.dataTextField = UITextField()
        
        self.dataTextField.translatesAutoresizingMaskIntoConstraints = false
        self.dataTextField.leftViewMode = .always
        self.dataTextField.autocorrectionType = .yes
        self.dataTextField.autocapitalizationType = .none
        self.dataTextField.textColor = AppthemeHandler.bodyTextColor
        self.dataTextField.backgroundColor = .white
        self.dataTextField.spellCheckingType = .no
        self.dataTextField.setLeftPaddingPoints(DataCaptureConstants.TEXT_FIELD_LEFT_PADDING)
        self.dataTextField.addLeftView()
        
        let emailCaptureSettings = self.documentCaptureSettings as? EmailCaptureSettings
        self.dataTextField.keyboardType = emailCaptureSettings?.keyboardType ?? UIKeyboardType.emailAddress
        self.dataTextField.textContentType = emailCaptureSettings?.contentType ?? UITextContentType.emailAddress
        self.dataTextField.attributedPlaceholder = NSAttributedString(
            string: emailCaptureSettings?.keyboardHint ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        self.dataTextField.layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
        self.dataTextField.layer.borderWidth = DataCaptureConstants.TEXT_FIELD_BORDER_WIDTH
        
        self.dataTextField.delegate = self
        
        view.addSubview(self.dataTextField)
        
        self.dataTextField.setContentHuggingPriority(UILayoutPriority(501), for: .vertical)
        self.buttonsStackView.setContentHuggingPriority(UILayoutPriority(501), for: .vertical)
        
        let textFieldTopConstraint = self.dataTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: DataCaptureConstants.TEXT_FIELD_TOP_PADDING)
        textFieldTopConstraint.priority = UILayoutPriority(500)
        
        var textFieldBottomConstraint = self.dataTextField.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: DataCaptureConstants.TEXT_FIELD_BOTTOM_PADDING)
        
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        if screenHeight <= DataCaptureConstants.SMALLER_DEVICES {
            textFieldBottomConstraint = self.dataTextField.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: DataCaptureConstants.TEXT_FIELD_BOTTOM_PADDING_SMALL_DEVICE)
        }
        
        textFieldBottomConstraint.priority = UILayoutPriority(500)
        
        NSLayoutConstraint.activate([
            textFieldTopConstraint,
            textFieldBottomConstraint,
            self.dataTextField.leadingAnchor.constraint(equalTo: sendOtpButton.leadingAnchor),
            self.dataTextField.heightAnchor.constraint(equalToConstant: DataCaptureConstants.TEXT_FIELD_HEIGHT),
            self.dataTextField.trailingAnchor.constraint(equalTo: sendOtpButton.trailingAnchor)
        ])
    }
    
    func canSubmitValidData() -> Bool {
        guard let emailAddress = self.dataTextField.text,
              !emailAddress.isEmpty else { return false }
        
        guard let emailCaptureSettings = self.documentCaptureSettings as? EmailCaptureSettings else { return false }
        
        let regex = emailCaptureSettings.regex
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: emailAddress)
    }
}
