//
//  AttributedStringProvider.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 24/09/25.
//

import UIKit

final class AttributedStringProvider {
    
    // MARK: - Singleton Instance
    static let shared = AttributedStringProvider()
    
    private init() {}
    
    private var attributedStrings: [String: NSAttributedString]? = nil
    var navigationTitle: NSAttributedString? = nil
    
    func fetchAttributedStringFor(_ key: String)  -> NSAttributedString? {
        return attributedStrings?[key]
    }
    
    func setAttributedStrings(_ attributedStrings: [String: NSAttributedString]) {
        self.attributedStrings = attributedStrings
    }
    
    func setNavigationTitle(_ text: NSAttributedString) {
        self.navigationTitle = text
    }
    
}
