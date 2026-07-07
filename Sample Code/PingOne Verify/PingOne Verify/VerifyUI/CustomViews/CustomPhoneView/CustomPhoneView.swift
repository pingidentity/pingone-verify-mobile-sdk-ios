//
//  PhoneView.swift
//  dropdownTest
//
//  Created by Caleb Cho on 3/1/23.
//

import UIKit

class CustomPhoneView: UIView {

    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let bundle: Bundle = Bundle(for: CustomPhoneView.self)
        bundle.loadNibNamed("CustomPhoneView", owner: self, options: nil)
        
        contentView.fixInView(self)
        
        self.countryCodeTextField.setLeftPaddingPoints(DataCaptureConstants.COUNTRY_CODE_TEXT_FIELD_LEFT_PADDING)
        self.phoneTextField.setLeftPaddingPoints(DataCaptureConstants.TEXT_FIELD_LEFT_PADDING)
    }
    
    func updateColor(color: UIColor) {
        DispatchQueue.main.async {
            self.divider.backgroundColor = color
            self.layer.borderColor = color.cgColor
        }
    }
}
