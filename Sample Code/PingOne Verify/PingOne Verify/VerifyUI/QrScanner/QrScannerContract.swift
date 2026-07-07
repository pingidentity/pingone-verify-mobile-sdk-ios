//
//  QrScannerProtocol.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/28/22.
//

import Foundation
import UIKit

public protocol QrScannerContract {
    @discardableResult func startQrScanner(pingOneNavController: UINavigationController, listener: QrScannerListener) -> UIViewController
}
