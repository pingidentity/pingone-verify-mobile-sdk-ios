//
//  QrScannerPresenter.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 4/1/22.
//

import Foundation
import UIKit

internal class QrScannerPresenter: QrScannerContract {    
    @discardableResult func startQrScanner(pingOneNavController: UINavigationController, listener: QrScannerListener) -> UIViewController {
        let qrController = self.getQrScannerViewController() as! QRScannerViewController
        qrController.setQrListener(listener: listener)
        
        pingOneNavController.pushViewController(qrController, animated: true)
        return qrController
    }
    
    func getQrScannerViewController() -> UIViewController {
        return QRScannerViewController(nibName: "QrScannerView", bundle: Bundle(for: type(of: self)))
    }
}
