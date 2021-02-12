//
//  StorageManager.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/03/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import P1Verify
import P1VerifyIDSchema
import CryptoTools

public class StorageManager {
    
    static let HAS_CARDS_DEFAULTS_KEY = "has_cards_defaults_key"
    static let REMOTE_PUSH_RECEIVED_NOTIFICATION_CENTER_KEY = "remote_push_received_notification_center_key"
    static let STORAGE_INITIALIZED_NOTIFICATION_CENTER_KEY = "storage_initialized_notification_center_key"
    static let CARD_ADDED_NOTIFICATION_CENTER_KEY = "card_added_notification_center_key"
    static let CARD_DELETED_NOTIFICATION_CENTER_KEY = "card_deleted_notification_center_key"
    static let IDV_STATUS_UPDATED_NOTIFICATION_CENTER_KEY = "idv_status_updated_notification_center_key"
    
    public static func hasCards() -> Bool {
        return UserDefaults.standard.bool(forKey: HAS_CARDS_DEFAULTS_KEY)
    }
    
    public static func initializeEncrypted(onComplete: @escaping (Bool) -> Void) {
        if let shared = Self.shared,
           let storage = shared.storage as? PersistentStorage, storage.encrypted {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: STORAGE_INITIALIZED_NOTIFICATION_CENTER_KEY)))
            onComplete(true)
            return
        }
        
        EncryptedDefaults.initialize { (result) in
            if case let .failure(error) = result {
                print(error.localizedDescription)
                onComplete(false)
                return
            }
            
            self.shared = StorageManager(storage: PersistentStorage(encrypted: true))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: STORAGE_INITIALIZED_NOTIFICATION_CENTER_KEY)))
            onComplete(true)
        }
    }
    
    //Must call initEncryptedStorage before and handle result if setting encrypted to true
    public static func initialize(persistentStorage: Bool) {
        if let shared = Self.shared {
            let isPersistent = shared.storage is PersistentStorage
            if (isPersistent != persistentStorage) {
                let storage: StorageProtocol = persistentStorage ? PersistentStorage(encrypted: false) : TempStorage()
                Self.shared = StorageManager(storage: storage)
                //TODO: port data over from other Storage
            }
        } else {
            let storage: StorageProtocol = persistentStorage ? PersistentStorage(encrypted: false) : TempStorage()
            shared = StorageManager(storage: storage)
        }
    }
    
    public static var shared: StorageManager!
    
    private var storage: StorageProtocol
    
    private init(storage: StorageProtocol) {
        self.storage = storage
    }
    
    func getVerificationStatus() -> VerifyStatus {
        return self.storage.getVerifyStatus()
    }
    
    func updateVerificationStatus(status: VerifyStatus) {
        self.storage.setVerifyStatus(status)
        NotificationCenter.default.post(name: NSNotification.Name(StorageManager.IDV_STATUS_UPDATED_NOTIFICATION_CENTER_KEY), object: nil, userInfo: ["verifyStatus": status.rawValue])
    }
    
    func getCardIds() -> [String] {
        return self.storage.getCardIds()
    }
    
    func getCardForId(_ cardId: String) -> IdCard? {
        return self.storage.getCardForId(cardId)
    }
    
    func getCardForType(_ cardType: String) -> IdCard? {
        return self.storage.getCardOfType(cardType)
    }
    
    func getCards() -> [IdCard] {
        var arr: [IdCard] = []
        for cardId in self.storage.getCardIds() {
            guard let card = self.storage.getCardForId(cardId) else {
                continue
            }
            arr.append(card)
        }
        return arr.sorted(by: { $0.cardType < $1.cardType })
    }
    
    func saveCard(card: IdCard) {
        DispatchQueue.global().async {
            if let card = self.getCardForType(card.cardType) {
                self.deleteCardForType(card.cardType)
            }
            self.storage.saveCard(card)
            UserDefaults.standard.set(true, forKey: StorageManager.HAS_CARDS_DEFAULTS_KEY)
            NotificationCenter.default.post(name: NSNotification.Name(StorageManager.CARD_ADDED_NOTIFICATION_CENTER_KEY), object: nil, userInfo: ["cardId": card.cardId])
        }
    }
    
    func deleteCardWithId(_ cardId: String) {
        self.storage.deleteCardWithId(cardId)
        self.onCardDeleted()
    }
    
    func deleteCardForType(_ cardType: String) {
        self.storage.deleteCardOfType(cardType)
        self.onCardDeleted()
    }
    
    private func onCardDeleted() {
        if (self.storage.cardIds.count == 0) {
            UserDefaults.standard.set(false, forKey: StorageManager.HAS_CARDS_DEFAULTS_KEY)
        }
        NotificationCenter.default.post(name: NSNotification.Name(StorageManager.CARD_DELETED_NOTIFICATION_CENTER_KEY), object: nil, userInfo: nil)
    }
    
    func deleteCards() {
        self.storage.deleteAll()
        self.onCardDeleted()
    }
    
    func resetVerifyStatus() {
        self.storage.resetVerifyStatus()
        NotificationCenter.default.post(name: NSNotification.Name(StorageManager.IDV_STATUS_UPDATED_NOTIFICATION_CENTER_KEY), object: nil)
    }
    
    func resetAll() {
        if self.storage is TempStorage {
            self.storage = TempStorage()
        } else if let persistentStorage = self.storage as? PersistentStorage  {
            persistentStorage.reset()
        }
        NotificationCenter.default.post(name: NSNotification.Name(StorageManager.CARD_DELETED_NOTIFICATION_CENTER_KEY), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(StorageManager.IDV_STATUS_UPDATED_NOTIFICATION_CENTER_KEY), object: nil)
    }
    
}
