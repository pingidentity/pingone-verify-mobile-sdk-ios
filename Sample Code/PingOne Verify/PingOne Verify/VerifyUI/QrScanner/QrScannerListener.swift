//
//  QrScannerListener.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/28/22.
//

import Foundation
import UIKit

/// Receives QR scanning results from the SDK's built-in QR scanner.
public protocol QrScannerListener: AnyObject {
    /// Called when the scanner successfully detects a QR code.
    ///
    /// - Parameters:
    ///   - viewController: The scanner view controller that produced the result.
    ///   - qrString: The raw string content encoded in the QR code.
    func onQrScanned(viewController: UIViewController, qrString: String)

    /// Called when the user dismisses the scanner without scanning a QR code.
    ///
    /// - Parameter viewController: The scanner view controller that was dismissed.
    func onQrScannerCanceled(viewController: UIViewController)
}
