//
//  CustomMenuItemCell.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 9/2/22.
//

import Foundation
import UIKit

protocol CustomMenuItemCell: UITableViewCell {
    static var nib: UINib {get}
    func populateCell(content: CustomMenuItemContent)
}

protocol CustomMenuItemContent {
    
}
