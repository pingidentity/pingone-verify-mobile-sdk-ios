//
//  WizardViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import P1VerifyIDSchema

class WizardStepViewController: UIViewController {
    
    var wizardPageContainerViewController: UIViewController?
    
    func moveToNextStep() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            guard let wizardPageViewController = self.wizardPageContainerViewController as? WizardPageViewController else {
                print("ViewController not child of a UIPageController.")
                return
            }
            
            wizardPageViewController.nextPage()
        }
    }
    
    func getContainerViewController() -> UIViewController {
        if let pageViewController = self.wizardPageContainerViewController as? WizardPageViewController {
            return pageViewController.containerViewController ?? pageViewController
        } else {
            return self.parent ?? self
        }
    }
    
    
}
