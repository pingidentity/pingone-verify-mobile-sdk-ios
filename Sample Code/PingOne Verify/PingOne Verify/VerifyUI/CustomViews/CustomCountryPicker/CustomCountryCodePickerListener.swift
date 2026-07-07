//
//  CustomCountryCodePickerListener.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 7/18/23.
//

import Foundation
import UIKit

/// Receives the result from the SDK's country-code picker UI.
///
/// Implement this protocol and pass it to the country-code picker view controller
/// to be notified when the user selects a country dialling code.
public protocol CustomCountryCodePickerListener {
    /// Called when the user selects a country dialling code.
    /// - Parameter code: The selected dialling code string (e.g. `"+1"`, `"+44"`).
    func onCountryCodePicked(code: String)
}
