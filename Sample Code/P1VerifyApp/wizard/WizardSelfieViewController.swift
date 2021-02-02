//
//  WizardSelfieViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import ShoLib
import P1VerifyIDSchema

class WizardSelfieViewController: WizardStepViewController {
    
    class func getViewController(containerViewController: UIViewController) -> WizardSelfieViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WizardSelfieViewController") as! WizardSelfieViewController
        vc.wizardPageContainerViewController = containerViewController
        return vc
    }
    
    @IBAction func onInfoClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "more_info_title".localized, message: "more_info_selfie".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
        alert.show()
    }
    
    @IBAction func onCaptureSelfieClicked(_ sender: UIButton) {
        let alertVc = UIAlertController(title: "Capture Selfie".localized, message: "capture_selfie_instructions".localized, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Continue".localized, style: .default, handler: { (_) in
            self.startLiveFaceVerificationVC()
        }))
        alertVc.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        self.present(alertVc, animated: true, completion: nil)
    }
    
    func startLiveFaceVerificationVC() {
        do {
            try LiveFaceVerificationViewController.Builder { (isComplete, selfie) in
                guard isComplete,
                      let selfie = selfie else {
                    return
                }
                
                let selfieCard = Selfie(selfie: selfie.getSelfie().fixPortraitOrientation().fitImageIn(maxSize: 1024))
                DispatchQueue.global().async {
                    print("Saving card \(selfieCard.cardType)")
                    StorageManager.shared.saveCard(card: selfieCard)
                    DispatchQueue.main.async {
                        self.moveToNextStep()
                    }
                }
            }
            .setAccuracy(accuracy: .low)
            .setVerificationTime(verificationTime: 2.0)
            .setVerificationSteps(verificationSteps: SCLiveFaceVerificationStep.lfv_smile, SCLiveFaceVerificationStep.lfv_straight_face)
            .create().show(parentViewController: self.getContainerViewController())
        } catch {
            print("Error capturing selfie: \(error.localizedDescription)")
            UIApplication.showErrorAlert(message: "generic_error_message", alertAction: nil)
        }
    }
}
