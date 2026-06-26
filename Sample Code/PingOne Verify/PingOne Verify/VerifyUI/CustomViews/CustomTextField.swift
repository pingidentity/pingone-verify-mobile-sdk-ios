//
//  CustomTextField.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 3/30/23.
//

import Foundation
import UIKit

class CustomTextField: UITextField {
    var verticalLeftView: UIView?
    let DEFAULT_FONT: UIFont = UIFont(name: "HelveticaNeue-Light", size: 15) ?? .systemFont(ofSize: 15)
    let ERROR_TEXTFIELD_COLOR = "error_textfield_color"
    
    static let LEFT_INSET: CGFloat = 16.0
    static let RIGHT_INSET: CGFloat = 16.0
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

        setupBackgroundView()
        setupLeftVerticalView()
        setupInputView()
        updateColor(isError: false)
    }
    
    init() {
        super.init(frame: CGRect())
        
        setupBackgroundView()
        setupLeftVerticalView()
        setupInputView()
        updateColor(isError: false)
    }
    
    var textPadding = UIEdgeInsets(
            top: 0,
            left: LEFT_INSET,
            bottom: 0,
            right: RIGHT_INSET
        )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func borderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.borderRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
 
    private func setupBackgroundView() {
        layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
        layer.borderWidth = DataCaptureConstants.TEXT_FIELD_BORDER_WIDTH
        borderStyle = .none
    }
    
    private func setupLeftVerticalView() {
        let viewRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 6, height: frame.height))
        verticalLeftView = UIView(frame: viewRect)
        if let verticalLeftView = verticalLeftView {
            verticalLeftView.clipsToBounds = true
            verticalLeftView.layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
            verticalLeftView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            addSubview(verticalLeftView)
        }
    }

    private func setupInputView() {
        keyboardType = .numberPad
        self.font = DEFAULT_FONT
    }
    
    func updateColor(isError: Bool) {
        let defaultBorderColor: UIColor? = AppthemeHandler.buttonColor
        let borderColor = isError ? UIColor.loadColor(named: self.ERROR_TEXTFIELD_COLOR) : defaultBorderColor
        
        self.verticalLeftView?.backgroundColor = borderColor
        tintColor = borderColor
        layer.borderColor = borderColor?.cgColor
        
        textColor = isError == true ? UIColor.loadColor(named: self.ERROR_TEXTFIELD_COLOR) : .black
    }
}
