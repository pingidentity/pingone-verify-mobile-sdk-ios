//
//  ImageCell.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/31/22.
//

import UIKit

import Foundation
import UIKit

class ImageCell: UITableViewCell, CustomMenuItemCell {

    static var nib: UINib {
        return UINib(nibName: "ImageCell", bundle: Bundle(for: Self.self))
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
    func populateCell(content: CustomMenuItemContent) {
        guard let content = content as? ImageCellContent else {
            return
        }
        
        self.titleLabel.text = content.label
        self.flagImageView.image = content.image
    }
}
