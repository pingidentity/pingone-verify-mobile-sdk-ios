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
    /// Screen element VoiceOver should focus on arrival (NEO-6568): the screen's header. Set by
    /// subclasses whose header lives in their own view; when nil, no focus move is posted.
    internal var accessibilityHeaderElement: NSObject?
    /// When true, the header focus is posted on arrival even if VoiceOver already reports its
    /// focus as being on the header. For screens whose header carries an announcement that must
    /// be spoken (it can otherwise be silent when VoiceOver auto-focuses it without speaking).
    internal var alwaysPostHeaderFocus = false
    /// Views (e.g. a close button) VoiceOver should not read on arrival, so the screen's header
    /// comes first. Hidden from VoiceOver when the screen appears and restored shortly after, so
    /// they are still read on touch or swipe.
    internal var arrivalDeferredAccessibilityViews: [UIView] = []
    
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
        self.restoreChromeAccessibility(after: 1.5)
        // VoiceOver: move the cursor past the nav-bar back button to the screen header so the
        // screen's identity is announced first (NEO-6568). .screenChanged with an element moves
        // VoiceOver focus to that element. Subclasses point accessibilityHeaderElement at their
        // header; the nav titleView is the logo (not a meaningful first stop).
        guard UIAccessibility.isVoiceOverRunning, let headerElement = self.accessibilityHeaderElement else { return }
        // Only while still the visible top screen: when the capture UI closes this controller
        // reappears just before the next screen is pushed, and a late post would steal focus
        // from it (e.g. "Scan your ID" read over the ID review screen).
        // Also only on first arrival (push): popping back to this screen — e.g. when the ID
        // scanner pops itself just before the review screen is pushed — must not re-announce
        // the header over the next screen's announcement.
        guard self.isMovingToParent, self.isShowingOnTop else { return }
        // VoiceOver settles its own focus (the nav-bar back button) a moment after a push, which
        // can land after a single immediate post. Check where focus is after a short delay and
        // re-post only if it isn't on the header yet; check once more to catch a late settle.
        self.moveVoiceOverFocus(to: headerElement, checkingAfter: [0.4, 0.6, 0.8, 1.0], forcePost: self.alwaysPostHeaderFocus)
    }

    private func moveVoiceOverFocus(to element: NSObject, checkingAfter delays: [TimeInterval], forcePost: Bool = false) {
        guard let delay = delays.first else { return }
        let remainingDelays = Array(delays.dropFirst())
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak element] in
            guard let self, let element, UIAccessibility.isVoiceOverRunning else { return }
            // Not on top yet (e.g. a provider flow is still unwinding): skip this check but keep
            // the later ones, so the header still gets focus once the screen is really showing.
            var stillForcing = forcePost
            if self.isShowingOnTop {
                let focusedElement = UIAccessibility.focusedElement(using: .notificationVoiceOver) as AnyObject?
                // forcePost: VoiceOver can report focus as already on the header without having
                // spoken it (silence on arrival), so post regardless — on the first check where
                // the screen is actually on top, not just the very first one (a two-sided ID
                // scan unwinds more screens, so the review screen can still be settling then).
                if forcePost || focusedElement !== element {
                    UIAccessibility.post(notification: .screenChanged, argument: element)
                    stillForcing = false
                }
            }
            self.moveVoiceOverFocus(to: element, checkingAfter: remainingDelays, forcePost: stillForcing)
        }
    }

    /// Bumped each time a screen hides its chrome (nav bar, session timer) from VoiceOver, so a
    /// delayed restore scheduled by an earlier screen can't un-hide it during a later screen's
    /// arrival. Main thread only.
    private static var chromeHideGeneration = 0
    private var chromeHideGeneration = 0

    /// VoiceOver: keep the nav-bar back button and the "Session expires in" label out of the
    /// arrival focus so the screen's header is read first (NEO-6568). Restored shortly after
    /// arrival, so both are still read when the user touches or swipes to them.
    private func hideChromeFromVoiceOverDuringArrival() {
        guard UIAccessibility.isVoiceOverRunning else { return }
        BaseViewController.chromeHideGeneration += 1
        self.chromeHideGeneration = BaseViewController.chromeHideGeneration
        self.navigationController?.navigationBar.accessibilityElementsHidden = true
        self.timerLabel?.isAccessibilityElement = false
        self.arrivalDeferredAccessibilityViews.forEach { $0.accessibilityElementsHidden = true }
    }

    private func restoreChromeAccessibility(after delay: TimeInterval) {
        let generation = self.chromeHideGeneration
        guard generation != 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak navigationBar = self.navigationController?.navigationBar] in
            guard BaseViewController.chromeHideGeneration == generation else { return }
            navigationBar?.accessibilityElementsHidden = false
            self?.timerLabel?.isAccessibilityElement = true
            self?.arrivalDeferredAccessibilityViews.forEach { $0.accessibilityElementsHidden = false }
        }
    }

    private var isShowingOnTop: Bool {
        return self.view.window != nil && self.navigationController?.topViewController === self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideChromeFromVoiceOverDuringArrival()
        self.updateNavigationController()
        self.setTimer()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
    }
}
