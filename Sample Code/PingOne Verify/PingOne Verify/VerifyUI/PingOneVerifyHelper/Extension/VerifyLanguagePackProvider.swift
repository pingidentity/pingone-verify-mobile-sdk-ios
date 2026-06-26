
//
//  VerifyLanguagePackProvider.swift
//  PingOneVerify
//

import NeoInterfaces

public class VerifyLanguagePackProvider {

    public var languagePackProvider: LanguagePackProviderContract
    public private(set) static var shared: VerifyLanguagePackProvider?

    static func initializeWith(languagePackProvider: LanguagePackProviderContract) {
        shared = VerifyLanguagePackProvider(languagePackProvider: languagePackProvider)
    }

    init(languagePackProvider: LanguagePackProviderContract) {
        self.languagePackProvider = languagePackProvider
    }

    func getStringForKey(_ key: String) -> String {
        let bundle = Bundle.forResource("PingOneVerifyLocalizable", ofType: "strings")
        return languagePackProvider.getStringForkey(key, bundle: bundle, defaultValue: key)
    }
}
