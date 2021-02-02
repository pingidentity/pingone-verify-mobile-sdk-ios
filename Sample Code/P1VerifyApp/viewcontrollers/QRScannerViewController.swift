//
//  QRScannerViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/17/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import ShoLib
import P1VerifyIDSchema

class QRScannerViewController: UIViewController, SCImageProcessingDelegate {
    
    @IBOutlet weak var cameraView: CameraView!
    
    var avWrapper: SCAVCaptureWrapper!
    var qrFound: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avWrapper = SCAVCaptureWrapper(captureView: self.cameraView, delegate: self, videoOrientation: .portrait)
        self.avWrapper.addMetadataCapture([.qr])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = self.avWrapper {
            self.avWrapper.hideQRBox()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.avWrapper.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.avWrapper.previewLayer.frame = self.cameraView.bounds
    }
    
    @IBAction func onCancelClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func hideQRBox() {
        self.avWrapper.hideQRBox()
    }
    
    func restartScanner() {
        self.avWrapper.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "manual_code_entry",
           let destinationVc = segue.destination as? TicketEntryViewController {
            destinationVc.parentScannerVc = self
        }
    }
    
    func capturedImage(_ image: UIImage, rect: CGRect) {
        print("Not capturing image here...")
    }
    
    func capturedMetadata(_ metadata: String) {
        guard !qrFound else {
            return
        }
        self.qrFound = true
        self.avWrapper.stop()
        self.navigationController?.dismiss(animated: true, completion: {
            IdvHelper.shared.submitVerificationData(ticketId: nil, qrUrl: metadata)
        })
        
    }
    
}
