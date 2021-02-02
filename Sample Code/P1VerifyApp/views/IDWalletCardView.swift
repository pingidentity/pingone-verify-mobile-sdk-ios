//
//  IDWalletCardView.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/13/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

class IDWalletCardView: UIView {
    
    static let FOCUSED_CARD_BG: UIColor = UIColor(netHex: 0xFCFAF7)
    static let UNFOCUSED_CARD_BG: UIColor = UIColor(netHex: 0xE0E0E0)
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var cardThumb: UIImageView!
    
    var cardBackgroundColor: UIColor = UIColor.clear {
        didSet {
            self.backgroundColor = self.cardBackgroundColor
            self.view.backgroundColor = self.cardBackgroundColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func setupView() {
        if let bundle = Bundle.main.loadNibNamed("IDWalletCardView", owner: self, options: nil){
            let subView = bundle[0] as! UIView
            subView.frame = self.bounds
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(subView)
        }
    }
    
}
