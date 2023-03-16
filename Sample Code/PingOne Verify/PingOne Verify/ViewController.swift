//
//  ViewController.swift
//  PingOne Verify
//
//  Created by Ping Identity on 10/26/22.
//  Copyright © 2023 Ping Identity. All rights reserved.
//

import UIKit
import PingOneVerify_iOS

class ViewController: UIViewController {
    
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func beginVerification() {
        PingOneVerifyClient.Builder()
            .setListener(self)
            .setRootViewController(self)
            .startVerification { pingOneVerifyClient, clientBuilderError in
                
                if let clientBuilderError = clientBuilderError {
                    logerror(clientBuilderError.localizedDescription ?? "")
                    let alertController = UIAlertController(title: "Client Builder Error", message: clientBuilderError.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .default))
                    if let presentedViewController = self.presentedViewController {
                        presentedViewController.dismiss(animated: true) {
                            self.present(alertController, animated: true)
                        }
                    } else {
                        self.present(alertController, animated: true)
                    }
                } else {
                    //Client object was initialized successfully and the SDK will return the results in callback methods
                }
                
            }
    }
    
}

extension ViewController: DocumentSubmissionListener {
    
    func onDocumentSubmitted(response: DocumentSubmissionResponse) {
        log("Document status: \(response.documentStatus.description)")
        log("Document submission status: \(response.documentSubmissionStatus.debugDescription)")
        log("Submitted documents: \(response.document?.keys.description ?? "Not available")")
    }
    
    func onSubmissionComplete(status: DocumentSubmissionStatus) {
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "completed_segue", sender: self)
            })
        }
    }
    
    func onSubmissionError(error: DocumentSubmissionError) {
        logerror(error.localizedDescription ?? "")
        let alertController = UIAlertController(title: "Document Submission Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default))
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.present(alertController, animated: true)
            })
        }
    }
}
