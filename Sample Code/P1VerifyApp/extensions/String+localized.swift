//
//  String+localized.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 12/04/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var localized: String {
        return self.localized(in: "Localizable")
    }
    
    func localized(_ args: CVarArg...) -> String {
        return String.init(format: localized, locale: Locale.current, arguments: args)
    }
    
}
