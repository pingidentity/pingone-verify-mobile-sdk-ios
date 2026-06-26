//
//  QrScanner2ViewController.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 5/26/22.
//

import UIKit

class QRScannerViewController: UIViewController, SCImageProcessingDelegate {

    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var qrLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var avWrapper: SCAVCaptureWrapper!
    var qrFound: Bool = false
    var qrScannerListener: QrScannerListener?
    
    internal var onQrFound: ((_ metadata: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.avWrapper = SCAVCaptureWrapper(captureView: self.cameraView, delegate: self, videoOrientation: .portrait)
        self.avWrapper.addMetadataCapture([.qr])
        
        self.qrLabel.text = "idv_qr_scan".localized
        
        let qrSannerStartAppEvent = AppEvent(key: AppEventConstants.QR_SCANNER_START, value: Date.currentTimeStamp)
        AppEventStorage.shared.addAppEvents(events: qrSannerStartAppEvent, eventType: .QR_SCANNER)
    }
    

    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.requestCameraPermission(dismiss: true)
        
        self.cameraView.addSubview(self.qrLabel)
        self.cameraView.addSubview(self.cancelBtn)

        if let _ = self.avWrapper {
            self.avWrapper.hideQRBox()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.restartScanner()
    }
    
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.avWrapper.stop()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        DispatchQueue.main.async {
            self.navigationController?.viewControllers.remove(at: 0)
        }
    }
    
    internal override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let _ = self.avWrapper.previewLayer {
            self.avWrapper.previewLayer.frame = self.cameraView.bounds
        }
    }
    
    @IBAction func onCancelBtnClicked(_ sender: UIButton) {
        qrScannerListener?.onQrScannerCanceled(viewController: self)
        
        let qrScannerCancelAppEvent = AppEvent(key: AppEventConstants.QR_SCANNER_CANCELLED, value: AppConstants.eventValueTrue)
        AppEventStorage.shared.addAppEvents(events: qrScannerCancelAppEvent, eventType: .QR_SCANNER)
        
        self.dismiss(animated: false)
    }
    
    func setQrListener(listener: QrScannerListener) {
        self.qrScannerListener = listener
    }
    
    func hideQRBox() {
        self.avWrapper.hideQRBox()
    }
    
    func restartScanner() {
        self.qrFound = false
        self.hideQRBox()
        self.avWrapper.start()
    }
        
    internal func capturedImage(_ image: UIImage, rect: CGRect) {
        log("Not capturing image")
    }
    
    internal func capturedMetadata(_ metadata: String) {
        guard !qrFound else {
            return
        }
        self.qrFound = true
        self.avWrapper.stop()
        
        let qrScannerStopAppEvent = AppEvent(key: AppEventConstants.QR_SCANNER_STOP, value: Date.currentTimeStamp)
        AppEventStorage.shared.addAppEvents(events: qrScannerStopAppEvent, eventType: .QR_SCANNER)
        
        self.qrScannerListener?.onQrScanned(viewController: self, qrString: metadata)
    }
}
