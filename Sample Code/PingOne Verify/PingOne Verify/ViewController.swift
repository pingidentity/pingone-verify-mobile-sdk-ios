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
            .setUIAppearance(self.getUiAppearanceSettings())
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
        var attributedStringDict: [String : NSAttributedString] = [:]
        
        let text = "Identity Verification"
        let identityString = NSMutableAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: 18),
                         .foregroundColor: UIColor.purple]
        )
        
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
        
        let readableText = "Are you able to Read?"
        let readableAttributedString = NSMutableAttributedString(
            string: readableText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_data_check_readable"] = readableAttributedString
        
        let retryText = "Is It Readable?"
        let retryAttributedString = NSMutableAttributedString(
            string: retryText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .foregroundColor: UIColor.purple]
        )
        attributedStringDict["idv_retry"] = retryAttributedString
        
        let emailText = "Attributed Please enter your email address here."
        let emailTextAttributedString = NSMutableAttributedString(
            string: emailText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 18),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_emailCapture_description"] = emailTextAttributedString
        
        let emailtext = "Step 1 of 5\nVerify Your Email"
        let emailattributedText = NSMutableAttributedString(
            string: emailtext,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.italicSystemFont(ofSize: 25),
                .backgroundColor: UIColor.lightGray
            ]
        )
        
        let centerRange = (emailtext as NSString).range(of: "Verify Your Email")
        emailattributedText.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: 25),
            .foregroundColor: UIColor.purple
        ], range: centerRange)
        attributedStringDict["idv_emailCapture_title"] = emailattributedText
        
        
        let phoneText = "Please enter your phone number here."
        let phoneTextAttributedString = NSMutableAttributedString(
            string: phoneText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 18),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_phoneCapture_description"] = phoneTextAttributedString
        
        let phoneHeadertext = "Step 2 of 5\nVerify Your Phone Number"
        let phoneHeadertextattributedText = NSMutableAttributedString(
            string: phoneHeadertext,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.italicSystemFont(ofSize: 25),
                .backgroundColor: UIColor.lightGray
            ]
        )
        
        let centerphoneRange = (phoneHeadertext as NSString).range(of: "Verify Your Phone Number")
        phoneHeadertextattributedText.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: 25),
            .foregroundColor: UIColor.purple
        ], range: centerphoneRange)
        attributedStringDict["idv_phoneCapture_title"] = phoneHeadertextattributedText
        
        let govText = "Step 3 of 5\nScan your government-issued ID"
        let govTextAttributedString = NSMutableAttributedString(
            string: govText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .backgroundColor: UIColor.lightGray]
        )
        
        let centerGovRange = (govText as NSString).range(of: "Scan your government-issued ID")
        govTextAttributedString.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: 25),
            .foregroundColor: UIColor.purple
        ], range: centerGovRange)
        
        attributedStringDict["idv_documentCapture_header_governmentId"] = govTextAttributedString
        
        let govDescText = "Scan your government-issued ID, preferably one that is still valid."
        let govDescTextAttributedString = NSMutableAttributedString(
            string: govDescText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_documentCapture_description_governmentId"] = govDescTextAttributedString
        
        let processingText = "Stay Chill, drink water!"
        let processingTextAttributedString = NSMutableAttributedString(
            string: processingText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_data_processing"] = processingTextAttributedString
        
        let selfieText = "Step 4 of 5\nChal beta selfie lele tu"
        let selfieTextAttributedString = NSMutableAttributedString(
            string: selfieText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .backgroundColor: UIColor.lightGray]
        )
        
        let centerSelfieRange = (selfieText as NSString).range(of: "Chal beta selfie lele tu")
        selfieTextAttributedString.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: 25),
            .foregroundColor: UIColor.purple
        ], range: centerSelfieRange)
        attributedStringDict["idv_documentCapture_header_selfie"] = selfieTextAttributedString
        
        let selfieDescText = "Acche se lena selfie"
        let selfieDescTextAttributedString = NSMutableAttributedString(
            string: selfieDescText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 18),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_documentCapture_description_selfie"] = selfieDescTextAttributedString
        
        let voiceText = "Step 5 of 5\nMeri Awaaz hi pehchan hai"
        let voiceTextAttributedString = NSMutableAttributedString(
            string: voiceText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 25),
                         .backgroundColor: UIColor.lightGray]
        )
        
        let centerVoiceRange = (voiceText as NSString).range(of: "Meri Awaaz hi pehchan hai")
        voiceTextAttributedString.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: 25),
            .foregroundColor: UIColor.purple
        ], range: centerVoiceRange)
        attributedStringDict["idv_documentCapture_header_voice"] = voiceTextAttributedString
        
        let VoiceDescText = "Awaaz Dooooo"
        let VoiceDescTextAttributedString = NSMutableAttributedString(
            string: VoiceDescText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 18),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_documentCapture_description_voice"] = VoiceDescTextAttributedString
        
        let recordText = "Awaaz Dijye"
        let recordTextAttributedString = NSMutableAttributedString(
            string: recordText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 18),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_voiceCapture_header_voice"] = recordTextAttributedString
        
        let voiceInstructionText = "Ye sab jo likha hai, boliye"
        let voiceInstructionTextAttributedString = NSMutableAttributedString(
            string: voiceInstructionText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 18),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_voiceCapture_instruction"] = voiceInstructionTextAttributedString
        
        let voiceCompleteText = "Sunn liya maine awaaz"
        let voiceCompleteTextAttributedString = NSMutableAttributedString(
            string: voiceCompleteText,
            attributes: [.paragraphStyle: paragraphStyle,
                         .font: UIFont.systemFont(ofSize: 18),
                         .backgroundColor: UIColor.lightGray]
        )
        attributedStringDict["idv_voice_complete"] = voiceCompleteTextAttributedString
        
        return UIAppearanceSettings()
            .setAttributedStrings(attributedStringDict)
            .showSessionExpiresTimer(true)
            .setNavigationTitle(identityString)
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
