//
//  EmailCaptureViewController.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/11/22.
//

import UIKit

class DataCaptureViewController: BaseViewController {
    /// The value the user actually typed/selected on the email or phone entry screen,
    /// captured locally so the OTP screen can show it even if the core's echoed-back
    /// `destination` doesn't reach the settings object.
    static var lastEnteredDestination: String = ""

    weak var coordinator: VerifyTransactionCoordinator?
    var showProcessing: (() -> Void)?
    var canSendVerificationCode: Bool = false {
        didSet {
            self.sendOtpButton.isEnabled = canSendVerificationCode
            self.sendOtpButton.alpha = canSendVerificationCode ? 1.0 : 0.5
        }
    }
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var sendOtpButton: VerifyButton!
    @IBOutlet weak var skipButton: BorderedButton!
    @IBOutlet weak var titleLabel: HeaderLabel!
    @IBOutlet weak var imageView: IconImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var dataLabel: UILabel!
    var dataOptionsButton: CustomMenuButton<LabelCell>!
    var dataTextField: UITextField!
        
    var data: String = ""
    
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    internal class func getViewController(coordinator: VerifyTransactionCoordinator, documentCaptureSettings: DocumentCaptureSettings, documentType: DocumentClass) -> DataCaptureViewController {
        let bundle: Bundle = Bundle(for: DataCaptureViewController.self)
        let informationCaptureViewController = DataCaptureViewController(nibName: "DataCaptureViewController", bundle: bundle)
        informationCaptureViewController.coordinator = coordinator
        informationCaptureViewController.documentCaptureSettings = documentCaptureSettings
        informationCaptureViewController.documentType = documentType

        return informationCaptureViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUIComponents()

        if let iconTintColor = TintColorHolderView.appearance().backgroundColor {
            self.updateBorderColors(color: iconTintColor.cgColor)
        }
        
        self.updateImage(with: IconImageView.appearance().tintColor)
        
        self.addAppEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.setUpConstraintsForSmallScreenDevices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PingOneVerifyNotification.BACK_BUTTON_PRESSED_NOTIFICATION_CENTER_KEY), object: self, userInfo: ["documentType": self.documentType as Any])
        }
                
        let stopAppEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_STOP, value: self.documentType.rawValue + "_" + DateUtil.getCurrentDate())
        AppEventStorage.shared.addAppEvents(events: stopAppEvent, eventType: .DATA_CAPTURE)
        AppEventManager.shared.flushAppEvents()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func sendOtpButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedClicks()
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        showProcessing?()
        coordinator?.skipDocument(type: self.documentType)
    }
    
    internal func updateBorderColors(color: CGColor) {
        self.dataTextField?.layer.borderColor = AppthemeHandler.buttonColor.cgColor
        self.dataOptionsButton?.layer.borderColor = color
        self.skipButton.layer.borderColor = color
    }
    
    internal func setUpUIComponents() {
        if documentType == .EMAIL {
            self.sendOtpButton.setTitle("idv_infoCapture_button".localized, for: .normal)
        } else if documentType == .PHONE {
            self.sendOtpButton.setTitle("idv_infoCapture_button".localized, for: .normal)
        }
        self.skipButton.setTitle("idv_skip".localized, for: .normal)
        self.updateSkipVisibility()
        self.setLabelDescriptions()
        self.updateValues()
    }
    
    func updateSkipVisibility() {
        if let optional = self.documentCaptureSettings?.optional {
            self.skipButton.isHidden = !optional
            self.skipButton.isEnabled = optional
        }
    }
    
    internal func setLabelDescriptions() {
        if documentType == .EMAIL {
            if let attributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_emailCapture_title") {
                self.titleLabel.attributedText = attributedText
            } else {
                let text = "idv_emailCapture_title".localized
                self.titleLabel.text = text
            }
        } else if documentType == .PHONE {
            if let attributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_phoneCapture_title") {
                self.titleLabel.attributedText = attributedText
            } else {
                let text = "idv_phoneCapture_title".localized
                self.titleLabel.text = text
            }
        }
    }
    
    private func updateImage(with color: UIColor?) {
        if let tintColor = color {
            self.imageView.image = UIImage.loadImage(named: self.documentType.iconName)?.withTintColor(tintColor).withRenderingMode(.alwaysOriginal)
        } else {
            self.imageView.image = UIImage.loadImage(named: self.documentType.iconName)
        }
    }
    
    private func updateValues() {
        let otpRequirements = (self.documentCaptureSettings as? OtpCaptureSettings)?.requirements?.requirementsValue
        if let value = otpRequirements?.getValue() {
            self.showDataValue(value: value)
            if let attributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_\(documentType.rawValue)Capture_description_value") {
                self.descriptionTextView.attributedText = attributedText
            } else {
                let text = "idv_\(documentType.rawValue)Capture_description_value".localized
                self.descriptionTextView.text = text
            }
        } else if let options = otpRequirements?.getOptions() {
            self.showDataOptionsButton(options: options)
            if let attributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_\(documentType.rawValue)Capture_description_option") {
                self.descriptionTextView.attributedText = attributedText
            } else {
                let text = "idv_\(documentType.rawValue)Capture_description_option".localized
                self.descriptionTextView.text = text
            }
        } else {
            self.showDataTextField()
            if let attributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_\(documentType.rawValue)Capture_description") {
                self.descriptionTextView.attributedText = attributedText
            } else {
                let text = "idv_\(documentType.rawValue)Capture_description".localized
                self.descriptionTextView.text = text
            }
        }
    }
    
    private func showDataValue(value: String) {
        self.dataLabel = UILabel()
        self.dataLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dataLabel.text = value
        self.dataLabel.textAlignment = .center
        self.dataLabel.font = UIFont.boldSystemFont(ofSize: DataCaptureConstants.LABEL_FONT_SIZE)

        view.addSubview(self.dataLabel)
         
        NSLayoutConstraint.activate([
            self.dataLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: DataCaptureConstants.LABEL_TOP_PADDING),
            self.dataLabel.leadingAnchor.constraint(equalTo: sendOtpButton.leadingAnchor),
            self.dataLabel.heightAnchor.constraint(equalToConstant: DataCaptureConstants.LABEL_HEIGHT),
            self.dataLabel.trailingAnchor.constraint(equalTo: sendOtpButton.trailingAnchor),
            self.dataLabel.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -DataCaptureConstants.LABEL_TOP_PADDING)
            ])
        
        self.data = value
        self.canSendVerificationCode = true
    }
    
    private func showDataOptionsButton(options: [String]) {
        self.dataOptionsButton = CustomMenuButton(showArrowImage: true, iconTintColor: TintColorHolderView.appearance().backgroundColor)
        self.dataOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let actions = options.map({ value in
            return UIAction(title: value) { _ in
                self.dataOptionsButton.setTitle(value, for: .normal)
                self.data = value
            }
        })
        
        self.dataOptionsButton.setTitle(options.first, for: .normal)
        view.addSubview(self.dataOptionsButton)
        
        let labelCell = (0..<options.count).map { LabelCellContent(label: options[$0])}
        
        self.setupDataOptionsMenuButton()
        self.dataOptionsButton.setItems(title: "idv_\(documentType.rawValue)Capture_menu_option".localized, actions, cellContent: labelCell, cellClass: LabelCell.self)
        
        if let first = options.first {
            self.data = first
        }
        self.canSendVerificationCode = true
    }
    
    private func setupDataOptionsMenuButton() {
        self.dataOptionsButton.layer.cornerRadius = DataCaptureConstants.OPTIONS_BUTTON_CORNER_RADIUS
        self.dataOptionsButton.layer.borderWidth = DataCaptureConstants.OPTIONS_BUTTON_BORDER_WIDTH
        
        self.dataOptionsButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.dataOptionsButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.dataOptionsButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.dataOptionsButton.imageView?.contentMode = .scaleAspectFit
        self.dataOptionsButton.backgroundColor = .white
        
        self.dataOptionsButton.sizeToFit()
        self.dataOptionsButton.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            self.dataOptionsButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: DataCaptureConstants.OPTIONS_BUTTON_TOP_PADDING),
   
            self.dataOptionsButton.leadingAnchor.constraint(equalTo: sendOtpButton.leadingAnchor),
            self.dataOptionsButton.heightAnchor.constraint(equalToConstant: DataCaptureConstants.OPTIONS_BUTTON_HEIGHT),
            self.dataOptionsButton.trailingAnchor.constraint(equalTo: sendOtpButton.trailingAnchor)
        ])
    }
    
    internal func showDataTextField() {

    }
    
    internal func addAppEvents() {
        let startAppEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_START, value: self.documentType.rawValue + "_" + DateUtil.getCurrentDate())
        
        guard let requirements = (self.documentCaptureSettings as? OtpCaptureSettings)?.requirements?.requirementsValue else { return }
        
        let hasRequirementsAppEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_REQUIREMENTS, value: self.documentType.rawValue + "_" + String(describing: requirements.hasRequirements()))
        
        AppEventStorage.shared.addAppEvents(events: startAppEvent, hasRequirementsAppEvent, eventType: .DATA_CAPTURE)
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: DataCaptureConstants.KEYBOARD_ANIMATION_DURATION) {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: DataCaptureConstants.KEYBOARD_ANIMATION_DURATION) {
                self.view.frame.origin.y = 0
            }
        }

        view.endEditing(true)
    }
}

extension DataCaptureViewController {
    func setUpConstraintsForSmallScreenDevices() {
        guard let imageViewTopConstraint = imageViewTopConstraint,
              let _ = imageViewWidthConstraint,
              let _ = imageViewHeightConstraint else { return }
        imageViewTopConstraint.constant = isSmallScreenDevice() ? 36 : 85
    }
    
    func isSmallScreenDevice() -> Bool {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return screenHeight <= DataCaptureConstants.SMALLER_DEVICES
    }
}
