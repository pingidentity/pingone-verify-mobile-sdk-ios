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
                if (error as? IdvError != IdvError.cannotInitializeIdvService("")) {
                    StorageManager.shared.updateVerificationStatus(status: .NOT_STARTED)
                }
            case .success(let status):
                StorageManager.shared.updateVerificationStatus(status: status)
            }
        }
    }
    
    private func submitVerificationData(ticketId: String?, qrUrl: String?, cards: [IdCard], onComplete: @escaping ((Result<VerifyStatus, Error>) -> Void)) {
        self.initIdvService(ticketId: ticketId, qrUrl: qrUrl) { (result) in
            switch result {
            case .failure(let error):
                onComplete(Result.failure(error))
            case .success(_):
                StorageManager.shared.updateVerificationStatus(status: .REQUESTED)
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
    
    public func handleResult(_ verificationResult: VerificationResult) {
        print("Verification Result: \(verificationResult.getValidationStatus())")
        if let userData = verificationResult.getUserData(), !userData.isEmpty() {
            self.updateIdCard(from: userData)
        } else {
            print("Verification Result doesn't contain any UserData")
        }
        if let verificationErrors = verificationResult.getValidationErrors() {
            verificationErrors.forEach { print("Error: \((try? $0.toJsonString()) ?? "Failed to parse to json") ") }
        }
        StorageManager.shared.updateVerificationStatus(status: verificationResult.getValidationStatus())
    }
    
    public func handleError(_ error: IdvError) {
        print("Error checking verification status: \(error.localizedDescription)")
        UIApplication.showErrorAlert(message: "check_status_error_message".localized, alertAction: nil)
    }
    
    private func updateIdCard(from userData: UserData) {
        print("Verified User Data: \((try? userData.toJsonString()) ?? "No user data")")
        
        switch userData.getCardType() {
        case IdCardKeys.cardTypeDriverLicense:
            self.updateDriverLicense(from: userData)
        case IdCardKeys.cardTypePassport:
            self.updatePassport(from: userData)
        default:
            return
        }
    }
 
    private func updateDriverLicense(from userData: UserData) {
        guard let card = StorageManager.shared.getCardForType(IdCardKeys.cardTypeDriverLicense),
              let driverLicense = card as? DriverLicense else {
            print("Cannot find card for type \(userData.getCardType())")
            return
        }
        driverLicense.setFirstName(userData.getFirstName().isEmpty ? driverLicense.getFirstName() : userData.getFirstName())
        driverLicense.setLastName(userData.getLastName().isEmpty ? driverLicense.getLastName() : userData.getLastName())
        driverLicense.setBirthDate(userData.getBirthDate().isEmpty ? driverLicense.getBirthDate() : userData.getBirthDate())
        driverLicense.setAddressStreet(userData.getAddressStreet().isEmpty ? driverLicense.getAddressStreet() : userData.getAddressStreet())
        driverLicense.setAddressCity(userData.getAddressCity().isEmpty ? driverLicense.getAddressCity() : userData.getAddressCity())
        driverLicense.setAddressState(userData.getAddressState().isEmpty ? driverLicense.getAddressState() : userData.getAddressState())
        driverLicense.setAddressZip(userData.getAddressZip().isEmpty ? driverLicense.getAddressZip() : userData.getAddressZip())
        driverLicense.setCountry(userData.getCountry().isEmpty ? driverLicense.getCountry() : userData.getCountry())
        driverLicense.setIdNumber(userData.getIdNumber().isEmpty ? driverLicense.getIdNumber() : userData.getIdNumber())
        driverLicense.setExpirationDate(userData.getExpirationDate().isEmpty ? driverLicense.getExpirationDate() : userData.getExpirationDate())
        driverLicense.setIssueDate(userData.getIssueDate().isEmpty ? driverLicense.getIssueDate() : userData.getIssueDate())
        
        StorageManager.shared.updateCard(card: driverLicense)
    }

    private func updatePassport(from userData: UserData) {
        guard let card = StorageManager.shared.getCardForType(IdCardKeys.cardTypePassport),
              let passport = card as? Passport else {
            print("Cannot find card for type \(userData.getCardType())")
            return
        }
        passport.setFirstName(userData.getFirstName().isEmpty ? passport.getFirstName() : userData.getFirstName())
        passport.setLastName(userData.getLastName().isEmpty ? passport.getLastName() : userData.getLastName())
        passport.setBirthDate(userData.getBirthDate().isEmpty ? passport.getBirthDate() : userData.getBirthDate())
        passport.setCountry(userData.getCountry().isEmpty ? passport.getCountry() : userData.getCountry())
        passport.setIdNumber(userData.getIdNumber().isEmpty ? passport.getIdNumber() : userData.getIdNumber())
        passport.setExpirationDate(userData.getExpirationDate().isEmpty ? passport.getExpirationDate() : userData.getExpirationDate())
        
        StorageManager.shared.updateCard(card: passport)

    }

}
