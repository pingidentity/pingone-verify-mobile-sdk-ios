//
//  WizardViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

class WizardViewController: UIViewController {
    
    @IBOutlet weak var pageViewControllerContainerView: UIView!
    
    var pageViewController: WizardPageViewController?
    var wizardSteps: [WizardStep] = [.captureSelfie, .captureDriverLicense, .capturePassport]
    
    static func startWizardFor(steps: [WizardStep]) -> WizardViewController {
        let wizardViewController: WizardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WizardViewController") as! WizardViewController
        wizardViewController.wizardSteps = steps
        return wizardViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(StorageManager.CARD_ADDED_NOTIFICATION_CENTER_KEY), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.navigationItem.hidesBackButton = true
                self.navigationItem.setLeftBarButton(nil, animated: false)
            }
        }
        if (wizardSteps.count == 1) {
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, identifier == "embedPageViewController",
              let destinationViewController = segue.destination as? WizardPageViewController else {
            return
        }
        self.pageViewController = destinationViewController
        self.pageViewController?.containerViewController = self
        self.pageViewController?.wizardSteps = self.wizardSteps
    }
    
    @IBAction func onCancelClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSkipClicked(_ sender: UIBarButtonItem) {
        self.pageViewController?.nextPage()
    }
}
