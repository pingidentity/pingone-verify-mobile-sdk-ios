//
//  WizardDriverLicenseViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import ShoLib
import P1VerifyIDSchema

class WizardDriverLicenseViewController: WizardStepViewController {
    
    class func getViewController(containerViewController: UIViewController) -> WizardDriverLicenseViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WizardDriverLicenseViewController") as! WizardDriverLicenseViewController
        vc.wizardPageContainerViewController = containerViewController
        return vc
    }
    
    @IBAction func onInfoClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "more_info_title", message: "more_info_driver_license".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
        alert.show()
    }

    @IBAction func onCaptureDLClicked(_ sender: UIButton) {
        DriverLicenseScannerViewController.Builder { (isComplete, driverLicense) in
            guard isComplete,
                  let dl = driverLicense else {
                return
            }
            DispatchQueue.global().async {
                do {
                    let resizedImage = dl.frontImage.fitImageIn(maxSize: 1024)
                    try dl.setFrontImage(resizedImage)
                } catch {
                    print("Failed to downsize image. App will save original image.")
                }
                dl.setBackImage(dl.getBackImage().fitImageIn(maxSize: 1024))
                print("Saving card \(dl.cardType)")
                StorageManager.shared.saveCard(card: dl)
                DispatchQueue.main.async {
                    self.moveToNextStep()
                }
            }
        }
        .create().show(parentViewController: self.getContainerViewController())
    }
    
}
