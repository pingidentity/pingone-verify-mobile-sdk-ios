//
//  LabelCell.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/31/22.
//

import Foundation
import UIKit

public class LabelCell: UITableViewCell, CustomMenuItemCell {
    
    static var nib: UINib {
        return UINib(nibName: "LabelCell", bundle: Bundle(for: Self.self))
    }

    @IBOutlet weak var label: UILabel!
    
    func populateCell(content: CustomMenuItemContent) {
        guard let content = content as? LabelCellContent else {
            return
        }
        
        self.label.text = content.label
    }
}

