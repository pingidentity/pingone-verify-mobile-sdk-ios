//
//  CustomToastView.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/29/23.
//

import Foundation
import UIKit

class CustomToastView: UIView {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    let DEFAULT_FONT: UIFont = .systemFont(ofSize: 18.0)
    let MIN_HEIGHT: CGFloat = 50.0
    let MARGIN: CGFloat = 45.0
    let ICON_WIDTH: CGFloat = 20.0
    let ICON_MARGIN: CGFloat = 25.0
    let TEXT_MARGIN: CGFloat = 15.0
    let BOTTOM_MARGIN: CGFloat = 40.0
    let ANIMATION_DURATION: CGFloat = 0.5
    let DISPLAY_DURATION: CGFloat = 3.0
    
    let SUCCESS_BACKGROUND_COLOR = "success_toast_background_color"
    let SUCCESS_TEXT_COLOR = "success_toast_text_color"
    let SUCCESS_ICON_IMAGE = "checkmark.circle.fill"
    let ERROR_BACKGROUND_COLOR = "error_toast_background_color"
    let ERROR_TEXT_COLOR = "error_toast_text_color"
    let ERROR_ICON_IMAGE = "exclamationmark.circle.fill"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle: Bundle = Bundle(for: CustomToastView.self)
        guard let toastView = bundle.loadNibNamed("CustomToastView", owner: self)?.first as? UIView else {
            return
        }
        
        addSubview(toastView)
        toastView.frame = bounds
        
        self.layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
        self.layer.masksToBounds = true
                
        messageLabel.textColor = .white
        messageLabel.font = self.DEFAULT_FONT
    }

    
    init(withError error: Bool, text: String) {
        guard let appDelegate = UIApplication.shared.delegate,
                let window = appDelegate.window,
                let window = window else {
            super.init(frame: .zero)
            return
        }

        let minHeight: CGFloat = self.MIN_HEIGHT
        let toastWidth: CGFloat = window.bounds.width - (self.MARGIN * 2)
        let stringWidth = toastWidth - (self.ICON_WIDTH + self.ICON_MARGIN + self.TEXT_MARGIN)
        let height = max(minHeight, text.getHeight(withConstrainedWidth: stringWidth, font: self.DEFAULT_FONT))

        super.init(frame: CGRect(x: (window.bounds.width - toastWidth) / 2, y: window.bounds.height - height - self.BOTTOM_MARGIN, width: toastWidth, height: height))

        commonInit()

        setupView(isError: error, text: text)
    }
    
    
    
    private func setupView(isError: Bool, text: String) {
        if isError {
            messageLabel.text = text
            messageLabel.textColor = UIColor.loadColor(named: self.ERROR_TEXT_COLOR)
            
            iconImage.image = UIImage(systemName: self.ERROR_ICON_IMAGE)
            iconImage.tintColor = UIColor.loadColor(named: self.ERROR_TEXT_COLOR)
            
            self.backgroundColor = UIColor.loadColor(named: self.ERROR_BACKGROUND_COLOR)
        } else {
            messageLabel.text = text
            messageLabel.textColor = UIColor.loadColor(named: self.SUCCESS_TEXT_COLOR)
            
            iconImage.image = UIImage(systemName: self.SUCCESS_ICON_IMAGE)
            iconImage.tintColor = UIColor.loadColor(named: self.SUCCESS_TEXT_COLOR)

            self.backgroundColor = UIColor.loadColor(named: self.SUCCESS_BACKGROUND_COLOR)
        }
    }
    
    private func loadView() {
        guard let appDelegate = UIApplication.shared.delegate,
                let window = appDelegate.window,
                let window = window else {
            return
        }
        
        let saveY = self.frame.origin.y
        self.frame.origin.y = window.bounds.maxY
        
        window.addSubview(self)
        
        UIView.animate(withDuration: self.ANIMATION_DURATION, animations: {
            self.frame.origin.y = saveY
        }) { _ in
            UIView.animate(withDuration: self.ANIMATION_DURATION, delay: self.DISPLAY_DURATION, animations: {
                self.frame.origin.y = window.bounds.maxY
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }
    
    class func display(isError: Bool, text: String) {
        DispatchQueue.main.async {
            let toastView = CustomToastView(withError: isError, text: text)
            toastView.loadView()
        }
    }
}
