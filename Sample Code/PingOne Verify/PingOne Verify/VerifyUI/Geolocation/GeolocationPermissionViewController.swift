//
//  GeolocationPermissionViewController.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 16/03/26.
//

import UIKit

class GeolocationPermissionViewController: BaseViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var continueButton: VerifyButton!
    @IBOutlet weak var permissionImageView: UIImageView!

    var coordinator: VerifyTransactionCoordinator?
    var isOptional = false

    override func viewDidLoad() {
        super.viewDidLoad()
        permissionImageView.image = UIImage.loadImage(named: "idv_geolocation_permission")
        setUpUIComponents()
    }

    internal class func getViewController(coordinator: VerifyTransactionCoordinator) -> GeolocationPermissionViewController {
        let bundle: Bundle = Bundle(for: GeolocationPermissionViewController.self)
        let geolocationViewController = GeolocationPermissionViewController(nibName: "GeolocationPermissionViewController", bundle: bundle)
        geolocationViewController.coordinator = coordinator
        return geolocationViewController
    }

    func setUpUIComponents() {
        self.overrideUserInterfaceStyle = .light
        self.continueButton.setTitle("idv_dataCapture_button".localized, for: .normal)
        if let headerAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_geolocation_title") {
            self.headerLabel.attributedText = headerAttributedText
        } else {
            self.headerLabel.text = "idv_geolocation_title".localized
        }
        if let descriptionAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_geolocation_description") {
            self.descriptionLabel.attributedText = descriptionAttributedText
        } else {
            self.descriptionLabel.text = "idv_geolocation_description".localized
        }
    }

    @IBAction func requestLocationPermission(_ sender: Any) {
        let status = coordinator?.isLocationPermissionGranted()

        switch status {
        case .authorizedWhenInUse:
            coordinator?.captureGeolocation()
        case .notDetermined:
            AppEventStorage.shared.addAppEvents(
                events: AppEvent(key: AppEventConstants.IS_LOCATION_PERMISSION_POPUP_SHOWN, value: AppConstants.eventValueTrue),
                eventType: .LOCATION_CAPTURE)
            coordinator?.captureGeolocation()

        case .denied:
            if let coordinator = coordinator {
                navigationController?.pushViewController(
                    GeolocationPermissionRetryViewController.getViewController(coordinator: coordinator),
                    animated: true)
            }
        case .restricted:
            break
        default:
            if let coordinator = coordinator {
                navigationController?.pushViewController(
                    GeolocationPermissionRetryViewController.getViewController(coordinator: coordinator),
                    animated: true)
            }
        }
    }
}
