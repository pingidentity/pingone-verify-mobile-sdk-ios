//
//  WizardPassportViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import ShoLib
import P1VerifyIDSchema

class WizardPassportViewController: WizardStepViewController {
    
    class func getViewController(containerViewController: UIViewController) -> WizardPassportViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WizardPassportViewController") as! WizardPassportViewController
        vc.wizardPageContainerViewController = containerViewController
        return vc
    }
    
    @IBAction func onInfoClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "more_info_title".localized, message: "more_info_passport".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
        alert.show()
    }

    @IBAction func onCapturePassportClicked(_ sender: UIButton) {
        PassportScannerViewController.Builder { (isComplete, passport) in
            guard isComplete,
                  let passport = passport else {
                return
            }
            DispatchQueue.global().async {
                do {
                    try passport.setFrontImage(passport.frontImage.fitImageIn(maxSize: 1024))
                } catch {
                    print("Failed to downsize image. App will save original image.")
                }
                print("Saving card \(passport.cardType)")
                StorageManager.shared.saveCard(card: passport)
                DispatchQueue.main.async {
                    self.moveToNextStep()
                }
            }
        }.create().show(parentViewController: self.getContainerViewController())
    }
    
}
