//
//  CountryCodes.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/18/22.
//

import Foundation

internal class CountryCodes {
    static func loadJson() -> [Country]? {
        let bundle = Bundle(for: Self.self)
        if let url = bundle.url(forResource: "countries", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode([Country].self, from: data)
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

internal struct Country: Decodable {
    var name: String
    var dialCode: String
    var code: String
}
