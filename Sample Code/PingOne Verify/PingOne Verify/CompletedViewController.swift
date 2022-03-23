//
//  CompletedViewController.swift
//  PingOneVerify_iOS_TestHostApp
//
//  Created by Caleb Cho on 9/7/22.
//

import UIKit

class CompletedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


//Extension for when you want to  as border color as a runtime attribute to any view
// borderColor property of a CALayer expects CGColor and you can pass only UIColor from Interface Builder.
// With this extension, you can use the attribute <layer.borderUIColor> and use UIColor to set the border color for the view.
internal extension CALayer {
    var borderUIColor: UIColor? {
        set {
            self.borderColor = newValue?.cgColor
        }
        get {
            return self.borderColor != nil ? UIColor(cgColor: self.borderColor!) : nil
        }
    }
}

