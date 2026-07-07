//
//  BaseViewController.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 7/15/22.
//

import Foundation
import UIKit

internal class BaseViewController: UIViewController {
    internal var timerLabel: UILabel?
    internal var timer: Timer?
    internal var timerTopConstraint: NSLayoutConstraint!
    internal var timerLabelText: String! {
        didSet {
            if let timerLabel = self.timerLabel,
                let timerLabelText = self.timerLabelText {
                DispatchQueue.main.async { timerLabel.text = timerLabelText }
            }
        }
    }
    static var appTheme: AppThemeResponse?
    static var showSessionExpirationTimer: Bool = true
    
    private var observer: NSObjectProtocol?
    
    internal var documentType: DocumentClass!
    internal var documentCaptureSettings: DocumentCaptureSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        if documentCaptureSettings?.isAuthflow == false && BaseViewController.showSessionExpirationTimer {
            self.setTimerLabel()
        }
        
        self.observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            DocumentSubmissionTimer.shared.updateTime()
        }

        let logoImageView = UIImageView(image: LogoImageView.appearance().image?.addImagePadding(x: 0, y: 10))
        logoImageView.contentMode = .scaleAspectFit
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 44))
        logoImageView.frame = titleView.bounds
        titleView.addSubview(logoImageView)

        if let attributedText = AttributedStringProvider.shared.navigationTitle {
            let titleLabel = UILabel()
            titleLabel.attributedText = attributedText
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.sizeToFit()
            titleLabel.accessibilityTraits = .header
            self.navigationItem.titleView = titleLabel
        } else {
            self.navigationItem.titleView = titleView
        }
    }
    
    deinit {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNavigationController()
        self.setTimer()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
    }
}
