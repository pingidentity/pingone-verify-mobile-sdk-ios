//
//  PhoneCaptureViewController2.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 4/14/23.
//

import UIKit

class PhoneCaptureViewController: DataCaptureViewController, UIGestureRecognizerDelegate {
    var filteredResults: [String]!
    var searchResults: [String]!
    var customPhoneView: CustomPhoneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    internal override class func getViewController(coordinator: VerifyTransactionCoordinator, documentCaptureSettings: DocumentCaptureSettings, documentType: DocumentClass) -> PhoneCaptureViewController {
        let bundle: Bundle = Bundle(for: PhoneCaptureViewController.self)
        let phoneCaptureViewController = PhoneCaptureViewController(nibName: "DataCaptureViewController", bundle: bundle)
        phoneCaptureViewController.coordinator = coordinator
        phoneCaptureViewController.documentCaptureSettings = documentCaptureSettings
        phoneCaptureViewController.documentType = documentType

        return phoneCaptureViewController
    }
    
    override func sendOtpButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedClicks()
        if let customPhoneView = self.customPhoneView, let phoneTextField = customPhoneView.phoneTextField {
            phoneTextField.resignFirstResponder()
        }
        if self.data.isEmpty {
            guard var countryCode = self.customPhoneView.countryCodeTextField.text,
                  let phoneNumber = self.customPhoneView.phoneTextField.text else { return }
            
            if countryCode.first != "+" {
                countryCode.insert("+", at: countryCode.startIndex)
            }
            
            self.data = "(\(countryCode))-\(phoneNumber)"
        }
        
        showProcessing?()
        coordinator?.submitPhone(self.data)
    }
    
    override func showDataTextField() {
        self.addObserver()
        
        self.customPhoneView = CustomPhoneView()
        self.customPhoneView.translatesAutoresizingMaskIntoConstraints = false
        self.customPhoneView.layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
        self.customPhoneView.layer.borderWidth = DataCaptureConstants.TEXT_FIELD_BORDER_WIDTH
        self.customPhoneView.phoneTextField.setLeftPaddingPoints(DataCaptureConstants.TEXT_FIELD_LEFT_PADDING)
        self.customPhoneView.countryCodeTextField.setLeftPaddingPoints(DataCaptureConstants.COUNTRY_CODE_TEXT_FIELD_LEFT_PADDING)
        
        self.customPhoneView.phoneTextField.delegate = self
        self.customPhoneView.countryCodeTextField.delegate = self
        
        view.addSubview(self.customPhoneView)
        
        guard let countries = CountryCodes.loadJson() else {
            return
        }
        
        self.filteredResults = countries.map({ $0.name + ": " + $0.dialCode})
        self.searchResults = countries.map({ $0.name + ": " + $0.dialCode})
                        
        self.customPhoneView.updateColor(color: AppthemeHandler.buttonColor)

        let phoneCaptureSettings = self.documentCaptureSettings as? PhoneCaptureSettings
        self.customPhoneView.phoneTextField.keyboardType = phoneCaptureSettings?.keyboardType ?? UIKeyboardType.phonePad
        self.customPhoneView.phoneTextField.textContentType = phoneCaptureSettings?.contentType ?? UITextContentType.telephoneNumber
        self.customPhoneView.phoneTextField.attributedPlaceholder = NSAttributedString(
            string: phoneCaptureSettings?.keyboardHint ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )

        self.customPhoneView.countryCodeTextField.text = "+1"
        self.customPhoneView.countryCodeTextField.addLeftView()

        NSLayoutConstraint.activate([
            self.customPhoneView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: DataCaptureConstants.TEXT_FIELD_TOP_PADDING),
            self.customPhoneView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: DataCaptureConstants.TEXT_FIELD_BOTTOM_PADDING),
            self.customPhoneView.leadingAnchor.constraint(equalTo: sendOtpButton.leadingAnchor),
            self.customPhoneView.trailingAnchor.constraint(equalTo: sendOtpButton.trailingAnchor)
        ])
    }
    
    func canSubmitValidData() -> Bool {
        guard let countryCode = self.customPhoneView.countryCodeTextField.text,
              !countryCode.isEmpty,
              PhoneCaptureUtils.isValidCountryCode(countryCode: countryCode) else { return false }
        
        guard let phoneNumber = self.customPhoneView.phoneTextField.text,
              !phoneNumber.isEmpty,
              PhoneCaptureUtils.isValidPhoneNumber(phoneNumber: phoneNumber) else { return false }
        
        return true
    }
}
