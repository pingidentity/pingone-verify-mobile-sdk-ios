//
//  UIViewController+createCancelBtn.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 6/2/22.
//

import Foundation
import UIKit

extension BaseViewController {
    internal func handleBackAction() {
        if let _ = self.navigationController {
            DispatchQueue.main.async {
                if let icon = UIImage.loadImage(named: "idv_back") {
                    let backButton = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(self.cancelClicked(sender:)))
                    self.navigationItem.leftBarButtonItem = backButton
                }  else {
                    logerror("Missing Back image")
                }
            }
        }
    }
    
    @objc func cancelClicked(sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: PingOneVerifyNotification.CANCELED_NOTIFICATION_CENTER_KEY), object: documentType, userInfo: [:])
    }
    
    internal func setTimerLabel() {
        self.timerLabel = UILabel(frame: CGRect(x: 0, y: Int((self.navigationController?.navigationBar.frame.height ?? DocumentSubmissionTimer.TIMER_FRAME_HEIGHT)) + DocumentSubmissionTimer.TIMER_Y_PADDING, width: DocumentSubmissionTimer.TIMER_WIDTH, height: DocumentSubmissionTimer.TIMER_HEIGHT))
        
        guard let timerLabel = self.timerLabel else { return }
        
        timerLabel.numberOfLines = 0
        timerLabel.textAlignment = .left
        timerLabel.text = "idv_timer_label".localized(DocumentSubmissionTimer.shared.timeRemaining?.stringDescription ?? "")
        timerLabel.font = .systemFont(ofSize: 16)
        timerLabel.textColor = AppthemeHandler.bodyTextColor
        self.view.addSubview(timerLabel)
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
                
        timerLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: DocumentSubmissionTimer.HORIZONTAL_CONSTANT).isActive = true
        timerLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -DocumentSubmissionTimer.HORIZONTAL_CONSTANT).isActive = true
        timerTopConstraint =  timerLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: DocumentSubmissionTimer.VERTICAL_CONSTANT)
        timerTopConstraint.isActive = true
    }
    
    internal func updateTimerLabelConstraint(forRecordScreen: Bool) {
        if forRecordScreen {
            timerTopConstraint.constant = DocumentSubmissionTimer.RECORD_VERTICAL_CONSTANT
        } else {
            timerTopConstraint.constant = DocumentSubmissionTimer.VERTICAL_CONSTANT
        }
        self.view.layoutIfNeeded()
        
    }
    
    internal func setTimer() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: DocumentSubmissionTimer.TIMER_INTERVAL_SECONDS, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimer() {
        self.timerLabelText = "idv_timer_label".localized(DocumentSubmissionTimer.shared.timeRemaining?.stringDescription ?? "")
    }
    
    internal func removeCompletedCaptureViewControllers() {
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1 else { return }

        if (navigationController.viewControllers.last is DocumentCaptureViewController &&
            (navigationController.viewControllers[navigationController.viewControllers.count - 2] is PreviewViewController || navigationController.viewControllers[navigationController.viewControllers.count - 2] is RetryViewController)) {
            DispatchQueue.main.async {
                self.navigationController?.viewControllers.remove(at: navigationController.viewControllers.count - 2)
            }
        }
    }
    
    internal func updateNavigationController() {
        self.handleBackAction()
        self.navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [PingOneNavController.self]).scrollEdgeAppearance
        self.navigationController?.navigationBar.tintColor = UINavigationBar.appearance(whenContainedInInstancesOf: [PingOneNavController.self]).tintColor
        self.removeCompletedCaptureViewControllers()
    }
}
