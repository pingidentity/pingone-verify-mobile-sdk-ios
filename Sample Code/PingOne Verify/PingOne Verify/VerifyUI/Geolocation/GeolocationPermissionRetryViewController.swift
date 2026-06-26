//
//  GeolocationPermissionRetryViewController.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 16/03/26.
//

import UIKit

class GeolocationPermissionRetryViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var retryButton: VerifyButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var retryImageView: UIImageView!
    var coordinator: VerifyTransactionCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        retryImageView.image = UIImage.loadImage(named: "idv_geolocation_retry")
        setUpUIComponents()
    }

    internal class func getViewController(coordinator: VerifyTransactionCoordinator) -> GeolocationPermissionRetryViewController {
        let bundle: Bundle = Bundle(for: GeolocationPermissionRetryViewController.self)
        let vc = GeolocationPermissionRetryViewController(nibName: "GeolocationPermissionRetryViewController", bundle: bundle)
        vc.coordinator = coordinator
        return vc
    }

    func setUpUIComponents() {
        self.overrideUserInterfaceStyle = .light
        self.retryButton.setTitle("idv_geolocation_retry".localized, for: .normal)
        if let headerAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_geolocation_retry_title") {
            self.headerLabel.attributedText = headerAttributedText
        } else {
            self.headerLabel.text = "idv_geolocation_retry_title".localized
        }
        if let descriptionAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_geolocation_retry_description") {
            self.descriptionLabel.attributedText = descriptionAttributedText
        } else {
            self.descriptionLabel.text = "idv_geolocation_retry_description".localized
        }
    }

    @IBAction func retryButtonTapped(_ sender: Any) {
        coordinator?.captureGeolocation()
    }
}
