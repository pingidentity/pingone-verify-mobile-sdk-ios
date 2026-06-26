//
//  String+UIImage.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 06/08/24.
//

import Foundation
import UIKit

extension String {
    
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
