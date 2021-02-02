//
//  WizardStep.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/21/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

enum WizardStep {
    
    case captureDriverLicense, capturePassport, captureSelfie
    
    func getViewController(containerViewController: UIViewController) -> WizardStepViewController {
        
        switch self {
        case .captureSelfie:
            return WizardSelfieViewController.getViewController(containerViewController: containerViewController)
        case .captureDriverLicense:
            return WizardDriverLicenseViewController.getViewController(containerViewController: containerViewController)
        case .capturePassport:
            return WizardPassportViewController.getViewController(containerViewController: containerViewController)
        }
        
    }
    
}
