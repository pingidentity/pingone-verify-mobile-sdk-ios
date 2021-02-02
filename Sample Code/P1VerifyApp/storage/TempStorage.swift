//
//  TempStorage.swift
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

class TempStorage: StorageProtocol {
    
    var cardIds: [String] = []
    var cards: [String: IdCard] = [:]
    var verifyStatus: VerifyStatus = .NOT_STARTED
    
    func saveCard(_ card: IdCard) {
        self.cardIds.append(card.cardId)
        self.cards[card.cardId] = card
    }
    
    func setVerifyStatus(_ verifyStatus: VerifyStatus) {
        self.verifyStatus = verifyStatus
    }
    
    func getCardIds() -> [String] {
        return self.cardIds
    }
    
    func getCardForId(_ cardId: String) -> IdCard? {
        return self.cards[cardId]
    }
    
    func getVerifyStatus() -> VerifyStatus {
        return self.verifyStatus
    }
    
    func resetVerifyStatus() {
        self.verifyStatus = .NOT_STARTED
    }
    
    func deleteCardWithId(_ cardId: String) {
        self.cardIds.removeAll(where: { $0 == cardId })
        self.cards.removeValue(forKey: cardId)
    }
    
    func deleteAll() {
        self.cardIds.removeAll()
        self.cards.removeAll()
    }
    
}
