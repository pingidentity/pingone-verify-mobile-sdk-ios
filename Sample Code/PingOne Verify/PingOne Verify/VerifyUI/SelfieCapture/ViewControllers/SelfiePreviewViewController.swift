//
//  SelfieCaptureViewController.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/19/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import UIKit

internal class SelfiePreviewViewController: BaseViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet public weak var nextButton: VerifyButton!
    @IBOutlet public weak var retakeButton: BorderedButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    private weak var coordinator: VerifyTransactionCoordinator?
    private var captureResult: SelfieCaptureResult!
    private var showProcessing: (() -> Void)?

    private static let BUTTON_CLICK_DELAY: TimeInterval = 2

    internal class func getViewController(result: SelfieCaptureResult, coordinator: VerifyTransactionCoordinator, showProcessing: @escaping () -> Void) -> SelfiePreviewViewController {
        let bundle: Bundle = Bundle(for: SelfiePreviewViewController.self)
        let selfiePreviewViewController = SelfiePreviewViewController(nibName: "SelfiePreviewView", bundle: bundle)
        selfiePreviewViewController.captureResult = result
        selfiePreviewViewController.coordinator = coordinator
        selfiePreviewViewController.showProcessing = showProcessing
        return selfiePreviewViewController
    }
    
    internal func show(parentViewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.modalPresentationStyle = .fullScreen
        parentViewController.present(self, animated: animated, completion: completion)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setUpUIComponents()
        self.previewImageView.contentMode = .scaleAspectFill
        self.previewImageView.image = self.captureResult.selfie.toImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setUpUIComponents() {
        self.nextButton.setTitle("idv_infoCapture_button".localized)
        self.retakeButton.setTitle("idv_data_check_retake".localized)
        self.closeButton.setTitle(nil, for: .normal)
        self.closeButton.backgroundColor = .clear
        self.closeButton.setImage(UIImage.loadImage(named: "idv_cancel")?.withTintColor(UIColor.loadColor(named: "idv_selfie_close") ?? .white), for: .normal)
        
        self.timerLabel?.isHidden = true
    }

    @IBAction func onNextButtonClicked(_ sender: UIButton) {
        sender.preventRepeatedClicks(inNext: Self.BUTTON_CLICK_DELAY)
        guard let coordinator = self.coordinator else { return }
        navigationController?.popViewController(animated: false)
        showProcessing?()
        coordinator.submitSelfie(captureResult)
    }

    @IBAction func onRetakeButtonClicked(_ sender: UIButton) {
        sender.preventRepeatedClicks(inNext: Self.BUTTON_CLICK_DELAY)
        guard let coordinator = self.coordinator else { return }
        guard let nav = navigationController else { return }
        nav.popViewController(animated: false)
        coordinator.captureSelfie(from: nav)
    }

    @IBAction func onCloseClicked(_ sender: UIButton) {
        if let docCaptureVC = navigationController?.viewControllers.last(where: { $0 is DocumentCaptureViewController }) {
            navigationController?.popToViewController(docCaptureVC, animated: true)
        } else {
            navigationController?.popViewController(animated: false)
        }
    }
}
