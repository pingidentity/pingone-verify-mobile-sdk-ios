//
//  VerifyButton.swift
//  PingOneVerify
//
//  Created by Bhavya Chauhan on 4/4/25.
//

import UIKit

public class VerifyButton: UIButton {

    private let buttonInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)

    public override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        return CGSize(
            width:  base.width  + buttonInsets.left + buttonInsets.right,
            height: base.height + buttonInsets.top  + buttonInsets.bottom
        )
    }

    @objc public dynamic var titleFont: UIFont? {
        set(font) {
            self.titleLabel?.font = font
        }
        get {
            return self.titleLabel?.font
        }
    }

    @objc public dynamic var cornerRadius: NSNumber? {
        set(radius) {
            self.layer.cornerRadius = CGFloat(radius?.floatValue ?? 0)
        }
        get {
            return NSNumber(value: Float(self.layer.cornerRadius))
        }
    }

    @objc public dynamic var fontColor: UIColor? {
        set(color) {
            self.setTextColor(color)
        }
        get {
            return self.currentTitleColor
        }
    }

    public func setTitle(_ title: String?) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .disabled)
        self.setTitle(title, for: .highlighted)
        self.setTitle(title, for: .focused)
        self.setTitle(title, for: .application)
        self.setTitle(title, for: .reserved)
        self.setTitle(title, for: .selected)
    }

    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.titleLabel?.font = UIFont.systemFont(ofSize: DataCaptureConstants.BUTTON_FONT_SIZE)
    }

    public func setTextColor(_ color: UIColor?) {
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(color, for: .disabled)
        self.setTitleColor(color, for: .highlighted)
        self.setTitleColor(color, for: .focused)
        self.setTitleColor(color, for: .application)
        self.setTitleColor(color, for: .reserved)
        self.setTitleColor(color, for: .selected)
    }

    override public func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        self.titleLabel?.font = UIFont.systemFont(ofSize: DataCaptureConstants.BUTTON_FONT_SIZE)
    }
}
