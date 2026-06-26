//
//  BaseViewControllerWithTextField.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 4/12/23.
//

import Foundation
import UIKit

internal class BaseViewControllerWithTextField: BaseViewController {
    private var keyboardVisibleHeight : CGFloat = 0
    private var isKeyboardVisible: Bool = false
    
    var bottomView: UIView!
    var offset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerKeyboardObservers()
    }
    
    func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        if (self.isKeyboardVisible || !self.bottomView.isDescendant(of: self.view)) {
            return
        }
        
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let frame = frameValue.cgRectValue
        self.keyboardVisibleHeight = frame.size.height
        
        let origin = self.view.subviews.contains(self.bottomView) ? bottomView.frame.origin : bottomView.convert(bottomView.frame.origin, to: self.view)
        let frameBottomCoordinates = CGPoint(x: origin.x, y: origin.y + bottomView.bounds.height)
        guard (frame.contains(frameBottomCoordinates)) else {
            return
        }
        
        self.offset = self.keyboardVisibleHeight
        self.view.frame.origin.y -= self.offset
        
        self.isKeyboardVisible = true
    }
    
    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
        
        self.isKeyboardVisible = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
