//
//  UIApplication+ErrorAlert.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/24/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func showErrorAlert(title: String = "Error".localized, message: String,
                        alertAction: ((UIAlertAction) -> Void)?) {
        DispatchQueue.main.async {
            let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: alertAction))
            alertVc.show()
        }
    }
    
}
