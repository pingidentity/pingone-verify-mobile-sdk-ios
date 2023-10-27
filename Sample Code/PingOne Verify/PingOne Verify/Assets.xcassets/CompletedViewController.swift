//
//  CompletedViewController.swift
//  PingOne Verify
//
//  Created by Ping Identity on 08/14/23.
//  Copyright © 2023 Ping Identity. All rights reserved.
//

import UIKit

class CompletedViewController: UIViewController {

    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.layer.cornerRadius = 8
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
