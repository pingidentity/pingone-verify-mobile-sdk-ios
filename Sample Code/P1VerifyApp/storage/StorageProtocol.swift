//
//  StorageProtocol.swift
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

protocol StorageProtocol {
    var cardIds: [String] {get set}
    var cards: [String: IdCard] {get set}
    var verifyStatus: VerifyStatus {get set}
    
    func getCardIds() -> [String]

    func saveCard(_ card: IdCard)
    func getCardOfType(_ cardType: String) -> IdCard?
    func getCardForId(_ cardId: String) -> IdCard?
    func deleteCardOfType(_ cardType: String)
    func deleteCardWithId(_ cardId: String)
    func deleteAll()
    
    func setVerifyStatus(_ verifyStatus: VerifyStatus)
    func getVerifyStatus() -> VerifyStatus
    func resetVerifyStatus()
 
}

extension StorageProtocol {
    
    func getCardOfType(_ cardType: String) -> IdCard? {
        return self.cards.first { $0.value.cardType == cardType }?.value
    }

    func deleteCardOfType(_ cardType: String) {
        self.cards.reduce(into: [String]()) {
            if ($1.value.cardType == cardType) {
                $0.append($1.value.cardId)
            }
            
        }.forEach( { self.deleteCardWithId($0) } )
    }

}
