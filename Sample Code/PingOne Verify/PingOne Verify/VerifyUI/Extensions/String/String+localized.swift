//
//  String+Localized.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 5/4/20.
//  Copyright © 2020 com.shocard. All rights reserved.
//

import Foundation

public extension String {

    var localized: String {
        if let provider = VerifyLanguagePackProvider.shared {
            return provider.getStringForKey(self)
        }
        let bundle = Bundle.forResource("PingOneVerifyLocalizable", ofType: "strings")
        return self.localized(tableName: "PingOneVerifyLocalizable", bundle: bundle, defaultValue: self)
    }
    
    func localized(in fileName: String) -> String {
        let bundle: Bundle = Bundle.forResource("PingOneVerifyLocalizable", ofType: "strings")
        return self.localized(tableName: fileName, bundle: bundle, defaultValue: self)
    }
    
    func localized(tableName: String, bundle: Bundle?, defaultValue: String) -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle ?? Bundle.main, value: defaultValue, comment: "")
    }

    func localized(in fileName: String, with args: CVarArg...) -> String {
        return String.init(format: localized(in: fileName), locale: Locale.current, arguments: args)
    }
    
    func localized(_ args: CVarArg...) -> String {
        return String.init(format: localized, locale: Locale.current, arguments: args)
    }
    
}

extension Bundle {

    static func forResource(_ name: String, ofType type: String) -> Bundle {
        if Bundle.main.path(forResource: name, ofType: type) != nil {
            return Bundle.main
        }
        let allBundles = Bundle.allFrameworks + Bundle.allBundles
        for bundle in allBundles where bundle.path(forResource: name, ofType: type) != nil {
            return bundle
        }
        return Bundle(for: DocumentPayload.self)
    }

}
