//
//  CardParamTableViewCell.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/13/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

class CardParamTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paramKey: UILabel!
    @IBOutlet weak var paramValue: UILabel!

    static var nib: UINib {
        return UINib(nibName: "CardParamTableViewCell", bundle: nil)
    }
    
}
