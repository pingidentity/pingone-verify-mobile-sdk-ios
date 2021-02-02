//
//  WizardPageViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

class WizardPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var wizardViewControllers: [WizardStepViewController] = []
    var containerViewController: UIViewController?
    var currentPageIndex: Int {
        if let firstViewController = self.viewControllers?.first as? WizardStepViewController {
            return self.wizardViewControllers.firstIndex(of: firstViewController) ?? 0
        }
        return 0
    }
    var wizardSteps: [WizardStep] = [.captureSelfie, .captureDriverLicense, .capturePassport]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.darkGray
        appearance.backgroundColor = UIColor.clear
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        self.prepareViewControllers()
    }
    
    func prepareViewControllers() {
        DispatchQueue.main.async {
            self.wizardViewControllers.removeAll()
            self.wizardViewControllers = self.wizardSteps.map( { return $0.getViewController(containerViewController: self) } )
            if let vc = self.wizardViewControllers.first {
                self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.wizardViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vc = viewControllers?.first as? WizardStepViewController,
              let vcIndex = self.wizardViewControllers.firstIndex(of: vc) else {
            return 0
        }
        return vcIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WizardStepViewController,
            let vcIndex = self.wizardViewControllers.firstIndex(of: vc) else {
            return nil
        }
        
        let nextIndex = vcIndex + 1
        guard nextIndex >= 0, self.wizardViewControllers.count > nextIndex else {
            return nil
        }
        
        return self.wizardViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WizardStepViewController,
              let vcIndex = self.wizardViewControllers.firstIndex(of: vc) else {
            return nil
        }
        
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0, self.wizardViewControllers.count > previousIndex else {
            return nil
        }
        
        return self.wizardViewControllers[previousIndex]
    }
    
    @discardableResult public func nextPage() -> Bool {
        let currentIndex = self.currentPageIndex
        let newIndex = currentIndex + 1
        guard newIndex >= 0, newIndex < self.wizardViewControllers.count else {
            guard IdvHelper.hasRequiredInfo() else {
                DispatchQueue.main.async {
                    let alertVc = UIAlertController(title: "insufficient_info_error_title".localized, message: "insufficient_info_error_message".localized, preferredStyle: .alert)
                    alertVc.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
                    alertVc.show()
                }
                return false
            }
            self.containerViewController?.navigationController?.popViewController(animated: true)
            return false
        }
        
        self.setViewControllers([self.wizardViewControllers[newIndex]], direction: .forward, animated: true, completion: nil)
        return true
   }
}
