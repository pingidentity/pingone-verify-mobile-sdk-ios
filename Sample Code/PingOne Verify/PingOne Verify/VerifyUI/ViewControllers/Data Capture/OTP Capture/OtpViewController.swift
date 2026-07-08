//
//  OtpViewController.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/11/22.
//

import UIKit

class OtpViewController: BaseViewController {

    @IBOutlet weak var titleLabel: HeaderLabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var submitPasscodeButton: VerifyButton!
    @IBOutlet weak var otpTimerLabel: UILabel!
    @IBOutlet weak var otpTextField: CustomTextField!
    @IBOutlet weak var submitPasscodeButtonBottomConstraint: NSLayoutConstraint!
    
    var originalButtonBottomConstant: CGFloat = 38
    var currentOffset: CGFloat = 0
    var originalY: CGFloat = 0
    var otpTextFieldOriginalY: CGFloat = 0
    
    var coordinator: VerifyTransactionCoordinator?
    var showProcessing: (() -> Void)?
    var otpSession: OtpSession!
    var otpDestination: String!
    var otpSettings: OtpCaptureSettings!
    private var resendCooldownTimer: Timer?

    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    internal var appForegroundObserver: NSObjectProtocol?
    
    internal var otpCount: Int = 1
    internal var otpTries: Int = 0

    internal class func getViewController(coordinator: VerifyTransactionCoordinator, documentCaptureSetting: DocumentCaptureSettings) -> OtpViewController? {
        guard let otpSettings = documentCaptureSetting as? OtpCaptureSettings else { return nil }
        let bundle: Bundle = Bundle(for: OtpViewController.self)
        let otpCaptureViewController = OtpViewController(nibName: "OtpViewController", bundle: bundle)
        otpCaptureViewController.coordinator = coordinator
        otpCaptureViewController.documentType = otpSettings.documentType
        otpCaptureViewController.otpDestination = otpSettings.destination.isEmpty
            ? DataCaptureViewController.lastEnteredDestination
            : otpSettings.destination
        otpCaptureViewController.otpSession = otpSettings.otpSession
        otpCaptureViewController.otpSettings = otpSettings
        return otpCaptureViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setOtpTextField()
        self.subscribeToTickers()
        self.setupDescriptionLabel()
        self.setupResendButton()
        self.addObserver()
        
        self.timerLabel?.isHidden = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapRecognizer)
        if let titleAttributedLabel = AttributedStringProvider.shared.fetchAttributedStringFor("idv_otp_title") {
            self.titleLabel.attributedText = titleAttributedLabel
        } else {
            self.titleLabel.text = "idv_otp_title".localized
        }
        
        self.addAppEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupDescriptionLabel() {
        let destination: String
        if self.otpDestination == "" {
            destination = self.documentType == .EMAIL
                ? "idv_otp_default_email".localized
                : "idv_otp_default_phone".localized
        } else {
            destination = self.otpDestination
        }
        self.descriptionTextView.text = "idv_otp_description".localized(destination)

        self.submitPasscodeButton.setTitle("idv_infoCapture_button".localized, for: .normal)
    }

    private func setOtpTextField() {
        self.otpTextField.overrideUserInterfaceStyle = .light
        self.otpTextField.backgroundColor = .white
        self.otpTextField.attributedPlaceholder = NSAttributedString(
            string: "idv_otp_title".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        self.otpTextField.layer.borderColor = AppthemeHandler.buttonColor.cgColor
        self.otpTextField.layer.borderWidth = DataCaptureConstants.TEXT_FIELD_BORDER_WIDTH
        self.otpTextField.layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
        self.otpTextField.delegate = self
        self.otpTextField.setLeftPaddingPoints(DataCaptureConstants.TEXT_FIELD_LEFT_PADDING)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.originalY = self.view.frame.origin.y
        self.originalButtonBottomConstant = 38
        self.submitPasscodeButtonBottomConstraint.constant = self.originalButtonBottomConstant
        self.otpTextFieldOriginalY = self.otpTextField.frame.origin.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let stopAppEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_OTP_STOP, value: self.documentType.rawValue + "_" + DateUtil.getCurrentDate())
        let otpNumberEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_NUMBER_OF_OTPS, value: self.documentType.rawValue + "_" + String(describing: self.otpCount))
        let otpTriesEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_OTP_TRIES, value: self.documentType.rawValue + "_" + String(describing: self.otpTries))
        
        AppEventStorage.shared.addAppEvents(events: stopAppEvent, otpNumberEvent, otpTriesEvent, eventType: .DATA_CAPTURE)
        AppEventManager.shared.flushAppEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isMovingFromParent || isBeingDismissed else { return }
        NotificationCenter.default.removeObserver(self)
        self.otpSettings?.otpExpiryTicker.onTick = nil
        self.resendCooldownTimer?.invalidate()
    }

    private func subscribeToTickers() {
        otpSettings.otpExpiryTicker.onTick = { [weak self] remaining in
            guard let self else { return }
            self.otpTimerLabel?.text = remaining > 0
                ? "idv_otp_time".localized(remaining.stringDescription)
                : ""
            if remaining <= 0 {
                let otpTimeoutAppEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_OTP_TIMEOUT, value: self.documentType.rawValue + "_" + AppConstants.eventValueTrue)
                AppEventStorage.shared.addAppEvents(events: otpTimeoutAppEvent, eventType: .DATA_CAPTURE)
            }
        }
    }

    internal func setupResendButton() {
        guard let canResend = self.otpSession.canResend else {
            self.resendButton.isHidden = true
            return
        }

        if canResend {
            self.resendButton.setTitle("idv_otp_resend".localized, for: .normal)
            self.resendButton.backgroundColor = UIColor.clear
            self.resendButton.setTitleColor(UIColor.systemBlue, for: .normal)
            self.resendButton.setTitleColor(UIColor.gray, for: .disabled)
            self.startResendCooldownTimer()
        } else {
            self.resendButton.isHidden = true
        }
    }

    /// Core sends only the raw `resendCooldown` timestamp on `otpSession`;
    /// the UI computes remaining time and schedules its own one-shot re-enable.
    private func startResendCooldownTimer() {
        resendCooldownTimer?.invalidate()
        resendCooldownTimer = nil

        guard let resendCooldown = self.otpSession.resendCooldown,
              let remaining = PingOneVerifyClientUtils.getRemainingDocumentSubmissionTime(expiresAt: resendCooldown, safetyTime: 0),
              remaining > 0 else {
            setResendButtonAvailable()
            return
        }

        self.resendButton.isEnabled = false
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.resendCooldownTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
                self?.setResendButtonAvailable()
            }
        }
    }

    private func setResendButtonAvailable() {
        self.resendButton.setTitle("idv_otp_resend".localized, for: .normal)
        self.resendButton.isEnabled = (self.otpSession.canResend ?? false)
        self.resendButton.alpha = 1.0
    }
    
internal func showError() {
        DispatchQueue.main.async {
            self.otpTextField.updateColor(isError: true)
            CustomToastView.display(isError: true, text: "idv_otp_invalid_code_error_description".localized)
            self.submitButtonEnabled(value: false)
        }
    }
    
    @IBAction func resendOtpButtonPressed(_ sender: UIButton) {
        self.resendButton.isEnabled = false
        self.otpCount = self.otpCount + 1
        coordinator?.resendOtp(for: self.documentType)
    }

    internal func handleOtpResult(_ success: Bool) {
        if success {
            self.otpTextField.updateColor(isError: false)
            let otpResultAppEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_OTP_RESULT, value: self.documentType.rawValue + "_" + AppConstants.eventValueTrue)
            AppEventStorage.shared.addAppEvents(events: otpResultAppEvent, eventType: .DATA_CAPTURE)
        } else {
            showError()
        }
    }

    internal func updateOtpSession(_ session: OtpSession) {
        self.otpSession = session
        DispatchQueue.main.async {
            self.setupResendButton()
        }
    }
    
    @IBAction func onSubmitButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedClicks()
        self.otpTextField.resignFirstResponder()
        self.submitPasscode()
    }
    
    internal func submitButtonEnabled(value: Bool) {
        DispatchQueue.main.async {
            self.submitPasscodeButton.alpha = value ? 1.0 : 0.5
            self.submitPasscodeButton.isEnabled = value
        }
    }
    
    internal func submitPasscode() {
        guard let passcode = self.otpTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        self.otpTries = self.otpTries + 1
        showProcessing?()
        coordinator?.submitOtp(passcode: passcode, otpType: self.documentType)
    }
    
    internal func addAppEvents() {
        let startAppEvent = AppEvent(key: AppEventConstants.DATA_CAPTURE_OTP_START, value: self.documentType.rawValue + "_" + DateUtil.getCurrentDate())
        AppEventStorage.shared.addAppEvents(events: startAppEvent, eventType: .DATA_CAPTURE)
    }
}
