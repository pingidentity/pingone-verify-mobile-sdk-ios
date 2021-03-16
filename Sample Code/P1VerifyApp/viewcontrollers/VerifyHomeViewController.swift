//
//  VerifyHomeViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/13/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import UIKit
import P1Verify
import P1VerifyIDSchema
import iCarousel
import ShoLib

class VerifyHomeViewController: UIViewController {
    
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var idvFailedView: UIView!
    @IBOutlet weak var idvInfoModifiedView: UIView!
    @IBOutlet weak var idvSuccessfulView: UIView!
    @IBOutlet weak var idvWaitingView: UIView!
    @IBOutlet weak var idvSubmittingView: UIView!
    @IBOutlet weak var idvNotStartedView: UIView!
    @IBOutlet weak var cardCarousel: iCarousel!
    @IBOutlet var qrScannerButton: UIBarButtonItem!
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    var currentVerifyStatus, previousStatus: VerifyStatus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeObservers()
        
        self.idvFailedView.isUserInteractionEnabled = true
        self.idvFailedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VerifyHomeViewController.onVerificationFailedClicked(_:))))
        
        if StorageManager.hasCards() {
            DispatchQueue.main.async {
                UIApplication.showWaitOverlay(message: "init_storage_busy".localized)
                DispatchQueue.global().async {
                    StorageManager.initializeEncrypted(onComplete: { (isInitialized) in
                        guard isInitialized else {
                            UIApplication.showErrorAlert(message: "failed_to_init_storage".localized, alertAction: nil)
                            return
                        }
                        DispatchQueue.main.async {
                            UIApplication.hideWaitOverlay()
                        }
                    })
                }
            }
        } else {
            self.initApp()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if StorageManager.hasCards() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               appDelegate.pnToken == nil {
                AppDelegate.registerForAPNS()
            }
            self.refreshHomeScreen()
        }
    }
    
    func initApp() {
        guard StorageManager.hasCards() else {
            self.title = ""
            self.navigationItem.setRightBarButton(nil, animated: false)
            self.navigationItem.setLeftBarButton(nil, animated: false)
            self.welcomeView.isHidden = false
            self.homeView.isHidden = true
            return
        }
        
        self.previousStatus = nil
        self.currentVerifyStatus = StorageManager.shared.getVerificationStatus()
        
        if (self.currentVerifyStatus == VerifyStatus.IN_PROGRESS) {
            IdvHelper.shared.startPollingForVerificationStatus()
        } else {
            IdvHelper.shared.stopPolling()
        }
        
        self.title = "Home".localized
        self.navigationItem.setRightBarButton(self.qrScannerButton, animated: true)
        self.navigationItem.setLeftBarButton(self.settingsButton, animated: true)
        self.welcomeView.isHidden = true
        self.homeView.isHidden = !StorageManager.hasCards()
        self.initializeCarousel()
        self.updateVerificationStatus()
    }
    
    func initializeObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(StorageManager.REMOTE_PUSH_RECEIVED_NOTIFICATION_CENTER_KEY), object: nil, queue: nil) { (notification) in
            IdvHelper.shared.processNotification(userInfo: notification.userInfo)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(StorageManager.STORAGE_INITIALIZED_NOTIFICATION_CENTER_KEY), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.initApp()
                if let userInfo = (UIApplication.shared.delegate as? AppDelegate)?.notificationUserInfo {
                    IdvHelper.shared.processNotification(userInfo: userInfo)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(StorageManager.IDV_STATUS_UPDATED_NOTIFICATION_CENTER_KEY), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.updateVerificationStatus()
                if (self.currentVerifyStatus == VerifyStatus.IN_PROGRESS) {
                    IdvHelper.shared.startPollingForVerificationStatus()
                } else {
                    IdvHelper.shared.stopPolling()
                }

                self.previousStatus = self.currentVerifyStatus
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(StorageManager.CARD_ADDED_NOTIFICATION_CENTER_KEY), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.refreshHomeScreen()
            }
        }
        
        NotificationCenter.default.addObserver(forName:  NSNotification.Name(StorageManager.CARD_DELETED_NOTIFICATION_CENTER_KEY), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.refreshHomeScreen()
                StorageManager.shared.updateVerificationStatus(status: .NOT_STARTED)
            }
        }
    }
    
    func initializeCarousel() {
        self.cardCarousel.type = .coverFlow2
        self.cardCarousel.bounces = false
        self.cardCarousel.isVertical = true
        self.cardCarousel.scrollSpeed = 2.0
        self.cardCarousel.centerItemWhenSelected = true
        
        self.cardCarousel.dataSource = self
        self.cardCarousel.delegate = self
        
        let width = self.cardCarousel.bounds.width
        let height = width * 0.77
        let cards = StorageManager.shared.getCardIds()
        let carouselHeight = height + (height * 0.33 * CGFloat(cards.count - 1))
        self.cardCarousel.frame.size.height = min(self.cardCarousel.frame.height, carouselHeight)
    }
    
    func refreshHomeScreen() {
        if (StorageManager.hasCards()) {
            if (homeView.isHidden) {
                self.initApp()
            }
            self.cardCarousel.reloadData()
        } else {
            self.homeView.isHidden = true
            self.welcomeView.isHidden = false
            self.navigationItem.setRightBarButton(nil, animated: false)
            self.navigationItem.setLeftBarButton(nil, animated: false)
        }
    }
    
    func updateVerificationStatus() {
        self.currentVerifyStatus = StorageManager.shared.getVerificationStatus()

        guard self.previousStatus != self.currentVerifyStatus else {
            return
        }

        let currentView = self.getViewFor(verificationStatus: self.currentVerifyStatus)
        
        if let previousStatus = self.previousStatus {
            let previousView = self.getViewFor(verificationStatus: previousStatus)
            
            if (previousView != currentView) {
                previousView.isHidden = true
                previousView.slideOutFromBottom(duration: 0.5)
            }
        } else {
            self.previousStatus = self.currentVerifyStatus
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            currentView.isHidden = false
            currentView.slideInFromTop(duration: 0.5)
        }
    }
    
    @objc func onVerificationFailedClicked(_ sender: UISwipeGestureRecognizer) {
        UIApplication.showErrorAlert(title: "verification_failed_error_title".localized, message: "verification_failed_error_message".localized, alertAction: nil)
    }
    
    func getViewFor(verificationStatus: VerifyStatus) -> UIView {
        switch verificationStatus {
        case .NOT_STARTED, .NOT_REQUIRED:
            return self.idvNotStartedView
        case .APPROVED_NO_REQUEST, .SUCCESS, .SUCCESS_MANUAL, .PARTIAL:
            return self.idvSuccessfulView
        case .IN_PROGRESS:
            return self.idvWaitingView
        case .REQUESTED:
            return self.idvSubmittingView
        case .FAIL:
            return self.idvFailedView
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "wizard_segue" {
            UIApplication.showWaitOverlay(message: "init_wizard_busy".localized)
            DispatchQueue.global().async {
                StorageManager.initializeEncrypted(onComplete: { (isInitialized) in
                    guard isInitialized else {
                        UIApplication.showErrorAlert(message: "failed_to_init_storage".localized, alertAction: nil)
                        return
                    }
                    DispatchQueue.main.async {
                        UIApplication.hideWaitOverlay()
                    }
                })
            }
        }
    }
    
}


extension VerifyHomeViewController: iCarouselDataSource, iCarouselDelegate {
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        //customize carousel display
        switch option {
        case .wrap:
            return 0.0
        case .spacing:
            return value * 0.3
        case .visibleItems:
            return 3
        case .tilt:
            return 0.8
        default:
            return value;
        }
    }
    
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return StorageManager.shared.getCards().count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let cards = StorageManager.shared.getCards()
        guard cards.count > 0 && index < cards.count  else {
            return UIView()
        }
        
        var cardView: IDWalletCardView
        var containerView: UIView
        if let view = view,
           let carouselCardView = view.viewWithTag(1001) as? IDWalletCardView {
            containerView = view
            cardView = carouselCardView
        } else {
            let width = self.cardCarousel.bounds.width
            let height = 0.77 * width
            let viewRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            containerView = UIView(frame: viewRect)
            cardView = IDWalletCardView(frame: viewRect)
            cardView.tag = 1001
            containerView.addSubview(cardView)
            
            containerView.viewBorderColor = UIColor(netHex: 0x999993)
            containerView.viewBorderWidth = 1
            containerView.viewCornerRadius = 8
        }
        containerView.backgroundColor = index == carousel.currentItemIndex ? IDWalletCardView.FOCUSED_CARD_BG : IDWalletCardView.UNFOCUSED_CARD_BG
        
        let card: IdCard = cards[index]
        
        cardView.cardThumb.contentMode = .scaleAspectFill
        cardView.cardName.text = IdCardKeys.getDisplayKeyFor(card.cardType)
        
        if let selfie = card as? Selfie {
            cardView.cardThumb.image = selfie.getSelfie()
        } else if let driverLicense = card as? DriverLicense {
            cardView.cardThumb.image = driverLicense.frontImage
        } else if let passport = card as? Passport {
            cardView.cardThumb.image = passport.frontImage
        }
        
        return containerView
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let cards = StorageManager.shared.getCards()
        guard cards.count > 0 && index < cards.count else {
            return
        }
        
        let selectedCard = cards[index]
        
        var cardParams = selectedCard.getClaims().filter( { $0.key != IdCardKeys.frontImage && $0.key != IdCardKeys.backImage })

        let frontImage: UIImage?
        let backImage: UIImage?
        
        if let selfie = selectedCard as? Selfie {
            frontImage = selfie.getSelfie()
            backImage = nil
        } else if let driverLicense = selectedCard as? DriverLicense {
            frontImage = driverLicense.frontImage
            backImage = driverLicense.getBackImage()
            
            cardParams = ValueFormatter.getFormattedDriverLicense(from: driverLicense).getClaims().filter( { $0.key != IdCardKeys.frontImage && $0.key != IdCardKeys.backImage })
        } else if let passport = selectedCard as? Passport {
            frontImage = passport.frontImage
            backImage = nil
            cardParams = passport.getClaims().filter( { $0.key != IdCardKeys.frontImage && $0.key != IdCardKeys.backImage })
        } else {
            frontImage = nil
            backImage = nil
        }
        
        let cardDetailsVc = CardDetailsViewController.getViewControllerFor(cardParams: cardParams, frontImage: frontImage, backImage: backImage)
        self.navigationController?.pushViewController(cardDetailsVc, animated: true)
    }
    
    
}
