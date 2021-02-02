//
//  WaitOverlayView.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/13/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import UIKit

class WaitOverlayView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!

    static var waitOverlayView: WaitOverlayView?
    private var onCancel: ((UIButton) -> ())!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    private func setupView() {
        if let bundle = Bundle.main.loadNibNamed("WaitOverlayView", owner: self, options: nil),
            let subview = bundle[0] as? UIView {
            subview.frame = self.bounds
            self.addSubview(subview)
        }
    }
    
    @IBAction func onCancelClicked(_ sender: UIButton) {
        self.onCancel(sender)
    }
    
    class func show(frame: CGRect = UIScreen.main.bounds, message: String = "Waiting...".localized, cancelable: Bool = false, onCancelClicked: ((UIButton) -> Void)? = nil) {
        DispatchQueue.main.async {
            let waitView = WaitOverlayView(frame: frame)
            
            waitView.cancelButton.setTitle("Cancel".localized, for: .normal)
            waitView.cancelButton.isHidden = !cancelable
            waitView.onCancel = {
                if (cancelable) {
                    hide()
                    onCancelClicked?($0)
                }
            }
            
            waitView.titleLabel.text = message
            waitView.activityIndicatorView.startAnimating()
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate ,
               let rootView = appDelegate.window {
                waitOverlayView = waitView
                rootView.addSubview(waitView)
            }
        }
    }
    
    class func hide() {
        DispatchQueue.main.async {
            if let waitView = waitOverlayView {
                waitView.removeFromSuperview()
                waitOverlayView = nil
            }
        }
    }
    
}
