//
//  SettingsViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import ShoLib

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsHeader: UILabel!
    @IBOutlet weak var versionString: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 4
        self.settingsHeader.isUserInteractionEnabled = true
        self.settingsHeader.addGestureRecognizer(tapGestureRecognizer)
        
        if let appVersion = StorageManager.getAppVersionAndBuild() {
            self.versionString.isHidden = false
            self.versionString.text = appVersion
        } else {
            self.versionString.isHidden = true
        }
    }
    
    @objc func headerViewTapped(sender: UITapGestureRecognizer) {
        let pnToken: String = (UIApplication.shared.delegate as? AppDelegate)?.pnToken?.hexDescription ?? "Not Available"
        let appId: String = Bundle.main.infoDictionary?["p1v_app_id"] as? String ?? "Not Available"
        let message: String = "Notification Token\n\(pnToken)\n\nApplication Id\n\(appId)"
        let alertVc = UIAlertController(title: "Debug Info", message: message, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Copy to Clipboard", style: .default) { action -> Void in
            let pasteboard:UIPasteboard = UIPasteboard.general
            pasteboard.string = message
        })
        alertVc.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        alertVc.show()
    }
    
    @IBAction func onCancelClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSelfieClicked(_ sender: UIButton) {
        self.dismissAndStartForWizardStep(.captureSelfie, sender: sender)
    }
    
    @IBAction func onDriverLicenseClicked(_ sender: UIButton) {
        self.dismissAndStartForWizardStep(.captureDriverLicense, sender: sender)
    }
    
    @IBAction func onPassportClicked(_ sender: UIButton) {
        self.dismissAndStartForWizardStep(.capturePassport, sender: sender)
    }
    
    @IBAction func onCheckVerificationClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            IdvHelper.shared.checkVerificationStatus()
        }
    }
    
    func dismissAndStartForWizardStep(_ wizardStep: WizardStep, sender: UIButton?) {
        sender?.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { [weak self] in
            guard let _ = sender, let _ = self else {
                return
            }
            sender?.isEnabled = true
        })
        let vc = WizardViewController.startWizardFor(steps: [wizardStep], isUpdatingDocument: true)
        if let parentViewController = self.navigationController?.presentingViewController as? UINavigationController {
            parentViewController.pushViewController(vc, animated: true)
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
