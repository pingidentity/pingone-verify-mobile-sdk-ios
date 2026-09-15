//
//  NfcCaptureViewController.swift
//  PingOneVerify
//

import UIKit

class NfcCaptureViewController: BaseViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: VerifyButton!
    @IBOutlet weak var iconImageView: IconImageView!

    var coordinator: VerifyTransactionCoordinator?

    internal class func getViewController(coordinator: VerifyTransactionCoordinator,
                                          settings: DocumentCaptureSettings) -> NfcCaptureViewController {
        let bundle: Bundle = Bundle(for: NfcCaptureViewController.self)
        let nfcCaptureViewController = NfcCaptureViewController(nibName: "NfcCaptureViewController", bundle: bundle)
        nfcCaptureViewController.coordinator = coordinator
        nfcCaptureViewController.documentCaptureSettings = settings
        nfcCaptureViewController.documentType = settings.documentType
        return nfcCaptureViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        self.continueButton.setTitle("idv_dataCapture_button".localized, for: .normal)
        self.headerLabel.text = "idv_nfc_title".localized
        self.descriptionLabel.text = "idv_nfc_description".localized
        self.updateIconImage()
    }

    /// The NFC illustration ships as three layers: `idv_rfid_body` (white line art),
    /// `idv_rfid_phonefill` (phone interior at partial alpha) and `idv_rfid_accent` (NFC waves +
    /// phone outline at full alpha). Both colour layers are tinted with the theme icon colour —
    /// the same source the other capture icons use — and composited over the body, so the phone
    /// fill reads as a light wash while the waves/outline stay solid.
    private func updateIconImage() {
        guard let body = UIImage.loadImage(named: "idv_rfid_body"),
              let accent = UIImage.loadImage(named: "idv_rfid_accent") else {
            self.iconImageView.image = UIImage.loadImage(named: "idv_rfid")
            return
        }
        let tint = IconImageView.appearance().tintColor ?? .black
        let tintedAccent = accent.withTintColor(tint, renderingMode: .alwaysOriginal)
        let tintedFill = UIImage.loadImage(named: "idv_rfid_phonefill")?
            .withTintColor(tint, renderingMode: .alwaysOriginal)
        let size = CGSize(width: body.size.width, height: body.size.height)
        self.iconImageView.image = UIGraphicsImageRenderer(size: size).image { _ in
            body.draw(in: CGRect(origin: .zero, size: size))
            tintedFill?.draw(in: CGRect(origin: .zero, size: size))
            tintedAccent.draw(in: CGRect(origin: .zero, size: size))
        }.withRenderingMode(.alwaysOriginal)
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        guard continueButton.isEnabled else { return }
        continueButton.isEnabled = false
        // documentCaptureSettings is always set by getViewController(coordinator:settings:).
        guard let settings = documentCaptureSettings else {
            logerror("NfcCaptureViewController presented without capture settings.")
            return
        }
        coordinator?.captureNfc(from: self, settings: settings)
    }
}
