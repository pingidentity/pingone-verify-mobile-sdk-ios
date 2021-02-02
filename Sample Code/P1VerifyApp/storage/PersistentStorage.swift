//
//  PersistentStorage.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/10/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import P1Verify
import P1VerifyIDSchema
import CryptoTools

class PersistentStorage: StorageProtocol {
    
    let CARD_DEFAULTS_KEY: String = "card_defaults_key"
    let CARD_IDS_ARRAY_DEFAULTS_KEY: String = "card_defaults_key.card_ids"
    let IDV_STATUS_DEFAULTS_KEY: String = "idv_status_defaults_key"
    let IDV_TX_ID_DEFAULTS_KEY: String = "idv_tx_id_defaults_key"
    
    let encrypted: Bool
    
    var cardIds: [String] = []
    var cards: [String : IdCard] = [:]
    var verifyStatus: VerifyStatus = .NOT_STARTED
        
    init(encrypted: Bool) {
        self.encrypted = encrypted
        self.cardIds = self.getArrayFromDefaults(forKey: CARD_IDS_ARRAY_DEFAULTS_KEY) as? [String] ?? []
        self.verifyStatus = VerifyStatus(rawValue: self.getStringFromDefaults(forKey: IDV_STATUS_DEFAULTS_KEY) ?? "") ?? .NOT_STARTED
    }
    
    func saveCard(_ card: IdCard) {
        self.cards[card.cardId] = card
        do {
            let _ = try card.toDictionary()
            let cardJson = try card.toJsonString()
            self.saveCardToFile(cardJson, forKey: "\(CARD_DEFAULTS_KEY).\(card.cardId)")
            
            if (!cardIds.contains(card.cardId)) {
                self.cardIds.append(card.cardId)
                self.saveArrayToDefaults(self.cardIds, forKey: CARD_IDS_ARRAY_DEFAULTS_KEY)
            }
        } catch {
            print("Error saving card. \(error.localizedDescription)")
        }
    }
    
    func setVerifyStatus(_ verifyStatus: VerifyStatus) {
        self.verifyStatus = verifyStatus
        self.saveStringToDefaults(self.verifyStatus.rawValue, forKey: IDV_STATUS_DEFAULTS_KEY)
    }
    
    func resetVerifyStatus() {
        self.verifyStatus = .NOT_STARTED
        self.removeDefaultsObject(forKey: IDV_STATUS_DEFAULTS_KEY)
    }

    func getCardIds() -> [String] {
        return self.cardIds
    }
    
    func getCardForId(_ cardId: String) -> IdCard? {
        guard self.cardIds.contains(cardId) else {
            return nil
        }
        
        if let card = self.cards[cardId] {
            return card
        }
        
        guard let cardJson = self.getCardFromFile(forKey: "\(CARD_DEFAULTS_KEY).\(cardId)"),
              let card = getCard(fromJson: cardJson) else {
            return nil
        }
        self.cards[cardId] = card
        return card
    }
    
    private func getCard(fromJson jsonString: String) -> IdCard? {
        do {
            guard let cardDictionary = try JsonHelper.decodeJson(jsonString.toData()) as? [String: Any],
                  let cardType = cardDictionary[IdCardKeys.cardType] as? String else {
                return nil
            }
            
            switch cardType {
            case IdCardKeys.cardTypeDriverLicense:
                return try DriverLicense(dict: cardDictionary)
            case IdCardKeys.cardTypePassport:
                return try Passport(dict: cardDictionary)
            case IdCardKeys.cardTypeSelfie:
                return try Selfie(dict: cardDictionary)
            default:
                return try Card(dict: cardDictionary)
            }
        } catch {
            print("Failed to load card. \(error.localizedDescription)")
            return nil
        }
    }
    
    func getVerifyStatus() -> VerifyStatus {
        return self.verifyStatus
    }
 
    func deleteCardWithId(_ cardId: String) {
        self.cardIds.removeAll(where: { $0 == cardId })
        self.saveArrayToDefaults(self.cardIds, forKey: CARD_IDS_ARRAY_DEFAULTS_KEY)
        self.cards.removeValue(forKey: cardId)
        self.removeDefaultsObject(forKey: "\(CARD_DEFAULTS_KEY).\(cardId)")
    }
    
    func deleteAll() {
        for cardId in self.cardIds {
            self.deleteCardWithId(cardId)
        }
    }
    
    func reset() {
        self.deleteAll()
        self.verifyStatus = .NOT_STARTED
        self.removeDefaultsObject(forKey: IDV_STATUS_DEFAULTS_KEY)
        self.removeDefaultsObject(forKey: IDV_TX_ID_DEFAULTS_KEY)
    }
    
    private func removeDefaultsObject(forKey key: String) {
        if (self.encrypted) {
            EncryptedDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    private func getCardFromFile(forKey key: String) -> String? {
        if (self.encrypted) {
            return PersistentStorage.decryptStringFromFile(key)
        } else {
            return UserDefaults.standard.string(forKey: key)
        }
    }
 
    private func saveCardToFile(_ value: String, forKey key: String) {
        if (self.encrypted) {
            print("Saving for key: \(PersistentStorage.encryptToFile(string: value, for: key))")
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
    private func getStringFromDefaults(forKey key: String) -> String? {
        if (self.encrypted) {
            return EncryptedDefaults.standard.string(forKey: key)
        } else {
            return UserDefaults.standard.string(forKey: key)
        }
    }
    
    private func saveStringToDefaults(_ value: String, forKey key: String) {
        if (self.encrypted) {
            EncryptedDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    private func getArrayFromDefaults(forKey key: String) -> [Any]? {
        if (self.encrypted) {
            return EncryptedDefaults.standard.array(forKey: key)
        } else {
            return UserDefaults.standard.array(forKey: key)
        }
    }
    
    private func saveArrayToDefaults(_ value: [Any], forKey key: String) {
        if (self.encrypted) {
            EncryptedDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    class func getDocumentsImagesURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesURL = documentsURL.appendingPathComponent("images")
        do {
            try FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        return imagesURL
    }
    
    class func getFileUrlFor(fileName: String) -> URL? {
        let fileURL = getDocumentsImagesURL().appendingPathComponent(fileName)
        return fileURL
    }
    
    class func encryptToFile(string: String, for fileName: String) -> Bool {
        if let url = PersistentStorage.getFileUrlFor(fileName: fileName) {
            do {
                try string.toData().write(to: url, options: .completeFileProtection)
                return true
            } catch {
                print("Failed to save data to file \(fileName) with 'completeFileProtection', will try to save it to EncryptedDefaults")
                return EncryptedDefaults.standard.set(string, forKey: fileName)
            }
        } else {
            return EncryptedDefaults.standard.set(string, forKey: fileName)
        }
    }
    
    class func decryptStringFromFile(_ fileName: String) -> String? {
        if let url = PersistentStorage.getFileUrlFor(fileName: fileName) {
            do {
                return try Data(contentsOf: url).toString()
            } catch {
                print("Failed to read data from file \(fileName) with 'completeFileProtection', will try to load it from EncryptedDefaults")
                return EncryptedDefaults.standard.string(forKey: fileName)
            }
        } else {
            return EncryptedDefaults.standard.string(forKey: fileName)
        }
    }
    
}
