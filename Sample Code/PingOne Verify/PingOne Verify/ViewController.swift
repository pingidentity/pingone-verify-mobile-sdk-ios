//
//  ViewController.swift
//  PingOne Verify
//
//  Created by Ping Identity on 10/26/22.
//  Copyright © 2025 Ping Identity. All rights reserved.
//

import UIKit
import PingOneVerify

class ViewController: UIViewController {
    
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func beginVerification() {
        PingOneVerifyClient.Builder(isOverridingAssets: false)
            .setListener(self)
            .setRootViewController(self)
            .setBackActionHandler(self)
//            .setUIAppearance(self.getUiAppearanceSettings())
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
    
    private func getUiAppearanceSettings() -> UIAppearanceSettings {
        let solidButtonAppearance = ButtonAppearance(backgroundColor: .red, textColor: .white, borderColor: .red)
        let borderedButtonAppearance = ButtonAppearance(backgroundColor: .clear, textColor: .red, borderColor: .red)
        
        let text = "Identity Verification"
        let identityString = NSMutableAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: 18),
                         .foregroundColor: UIColor.purple]
        )
        
        var attributedStringDict: [String : NSAttributedString] = [:]

        let clearText = "Is It Readable?"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let clearAttributedString = NSMutableAttributedString(
            string: clearText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_data_check_clear"] = clearAttributedString
        
        return UIAppearanceSettings()
            .setSolidButtonAppearance(solidButtonAppearance)
            .setBorderedButtonAppearance(borderedButtonAppearance)
            .setAttributedStrings(attributedStringDict)
            .showSessionExpiresTimer(false)
            .setNavigationTitle(identityString)
    }
}

extension ViewController: DocumentSubmissionListener, BackActionListener {
    
    func onDocumentSubmitted(response: DocumentSubmissionResponse) {
        // NOTE: Check for Credential type before fetching cred verification links
//        let collectionType = response.getCollectionType()
//        let links = response.getCredentialVerificationLinks()
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
        let alertController = UIAlertController(title: "Document Submission Error", message: "Error Code: \(error.getErrorCode())\n\nError Message: \(error.getErrorMessage())", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default))
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.present(alertController, animated: true)
            })
        }
    }
    
    func onBackAction(exitFlow: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "Cancel Transaction", message: "Do you want to cancel this transaction?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            exitFlow(true)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            exitFlow(false)
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.presentedViewController?.present(alertController, animated: true)
    }
    
}
