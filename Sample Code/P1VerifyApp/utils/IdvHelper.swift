//
//  IdvHelper.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/06/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import P1Verify
import P1VerifyIDSchema

public class IdvHelper {
    
    private static let POLL_FOR_VALIDATION_STATUS_KEY = "POLL_FOR_VALIDATION_STATUS"
    
    private static var _shared: IdvHelper!
    public static var shared: IdvHelper! {
        if let shared = _shared {
            return shared
        } else {
            _shared = IdvHelper()
            return _shared
        }
    }
    
    private var pollingHelper: PollingHelper?
    
    private init() {}
    
    private var idvService: IdvService?
    
    private func initIdvService(ticketId: String?, qrUrl: String?, onComplete: @escaping (Result<Bool, Error>) -> Void) {
        let builder: IdvService.Builder
        if let shortCode = ticketId {
            builder = IdvService.Builder.initWithNewConfig(for: shortCode)
        } else if let shortCodeUrl = qrUrl {
            builder = IdvService.Builder.initWithNewConfigFromQr(shortCodeUrl)
        } else {
            builder = IdvService.Builder.initWithSavedConfig()
        }
        
        DispatchQueue.main.async {
            #if DEBUG
            builder.setPushSandbox(true)
            #else
            builder.setPushSandbox(false)
            #endif
            
            builder.setNotificationHandler(self)
            if let pnToken = (UIApplication.shared.delegate as? AppDelegate)?.pnToken {
                builder.setPushNotificationToken(pnToken)
            }
            DispatchQueue.global().async {
                builder.create { (result) in
                    switch result {
                    case .failure(let error):
                        onComplete(Result.failure(error))
                    case .success(let idvService):
                        self.idvService = idvService
                        onComplete(Result.success(true))
                    }
                }
            }
        }
    }
    
    public func processNotification(userInfo: [AnyHashable: Any]?) {
        if (self.idvService == nil) {
            self.initIdvService(ticketId: nil, qrUrl: nil) { (result) in
                switch result {
                case .failure(let error):
                    self.handleError(error as? IdvError ?? IdvError.cannotInitializeIdvService(error.localizedDescription))
                case .success(_):
                    self.processPingOneNotification(userInfo: userInfo)
                }
            }
            return
        }
        
        self.processPingOneNotification(userInfo: userInfo)
    }
    
    private func processPingOneNotification(userInfo: [AnyHashable: Any]?) {
        guard let idvService = self.idvService else {
            return
        }
        if (!idvService.processNotification(userInfo: userInfo)) {
            // Notification cannot be handled by SDK
            // Handle your app notifications here
        }
    }
    
    public func submitVerificationData(ticketId: String?, qrUrl: String?, pollForResult: Bool = true) {
        self.stopPolling()
        UserDefaults.standard.set(pollForResult, forKey: IdvHelper.POLL_FOR_VALIDATION_STATUS_KEY)
        
        guard let cards = IdvHelper.getVerificationInfo() else {
            UIApplication.showErrorAlert(title: "missing_info_error_title".localized, message: "missing_info_error_message".localized, alertAction: nil)
            return
        }
        
        self.submitVerificationData(ticketId: ticketId, qrUrl: qrUrl, cards: cards) { (result) in
            switch result {
            case .failure(let error):
                print("Error submitting data: \(error.localizedDescription)")
                UIApplication.showErrorAlert(message: "submit_data_error_message".localized, alertAction: nil)
                StorageManager.shared.updateVerificationStatus(status: .NOT_STARTED)
            case .success(let status):
                StorageManager.shared.updateVerificationStatus(status: status)
            }
        }
    }
    
    private func submitVerificationData(ticketId: String?, qrUrl: String?, cards: [IdCard], onComplete: @escaping ((Result<VerifyStatus, Error>) -> Void)) {
        StorageManager.shared.updateVerificationStatus(status: .REQUESTED)
        self.initIdvService(ticketId: ticketId, qrUrl: qrUrl) { (result) in
            switch result {
            case .failure(let error):
                onComplete(Result.failure(error))
            case .success(_):
                self.idvService!.submitDataForVerification(data: cards, onComplete: { (result) in
                    onComplete(result.mapError( { return $0 as Error } ))
                })
            }
        }
    }
    
    public func checkVerificationStatus() {
        if (self.idvService == nil) {
            self.initIdvService(ticketId: nil, qrUrl: nil) { (result) in
                switch result {
                case .failure(let error):
                    self.handleError(error as? IdvError ?? IdvError.cannotInitializeIdvService(error.localizedDescription))
                case .success(_):
                    self.idvService?.checkVerificationStatus()
                }
            }
            return
        }
        
        self.idvService?.checkVerificationStatus()
    }
    
    public func startPollingForVerificationStatus() {
        guard UserDefaults.standard.bool(forKey: IdvHelper.POLL_FOR_VALIDATION_STATUS_KEY) else {
            return
        }
        
        if self.pollingHelper == nil {
            self.pollingHelper = PollingHelper(withInterval: 5.0, action: { (_) in
                self.checkVerificationStatus()
            })
        }
        
        self.pollingHelper?.startPolling()
    }
    
    public func stopPolling() {
        self.pollingHelper?.stopPolling()
    }
    
    public static func hasRequiredInfo() -> Bool {
        return StorageManager.shared.getCardForType(IdCardKeys.cardTypeSelfie) != nil &&
            (StorageManager.shared.getCardForType(IdCardKeys.cardTypeDriverLicense) != nil || StorageManager.shared.getCardForType(IdCardKeys.cardTypePassport) != nil)
        
    }
    
    public static func getVerificationInfo() -> [IdCard]? {
        guard let selfie = StorageManager.shared.getCardForType(IdCardKeys.cardTypeSelfie) else {
            return nil
        }
        
        let driverLicense = StorageManager.shared.getCardForType(IdCardKeys.cardTypeDriverLicense)
        let passport = StorageManager.shared.getCardForType(IdCardKeys.cardTypePassport)
        
        if let driverLicenseCard = driverLicense {
            return [selfie, driverLicenseCard]
        } else if let passportCard = passport {
            return [selfie, passportCard]
        }
        
        return nil
    }
    
}

extension IdvHelper: NotificationHandler {
    
    public func handlerResult(_ verificationResult: VerificationResult) {
        print("Verification Result: \(verificationResult.getValidationStatus())")
        if let verificationErrors = verificationResult.getValidationErrors() {
            verificationErrors.forEach { print("Error: \((try? $0.toJsonString()) ?? "Failed to parse to json") ") }
        }
        StorageManager.shared.updateVerificationStatus(status: verificationResult.getValidationStatus())
    }
    
    public func handleError(_ error: IdvError) {
        print("Error checking verification status: \(error.localizedDescription)")
        UIApplication.showErrorAlert(message: "check_status_error_message".localized, alertAction: nil)
    }
    
    
}
