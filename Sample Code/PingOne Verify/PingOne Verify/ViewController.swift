//
//  ViewController.swift
//  PingOneVerify_iOS_TestHostApp
//
//  Created by Caleb Cho on 3/25/22.
//

import UIKit
import PingOneVerify

class ViewController: UIViewController {

    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!

    private let spinnerOverlay: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.isHidden = true
        return v
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.color = .white
        s.hidesWhenStopped = true
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.beginButton.layer.cornerRadius = 8
        view.addSubview(spinnerOverlay)
        spinnerOverlay.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinnerOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spinnerOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spinnerOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            spinnerOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spinner.centerXAnchor.constraint(equalTo: spinnerOverlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: spinnerOverlay.centerYAnchor)
        ])
    }

    // MARK: - Built-in UI flow

    @IBAction func beginVerification() {
        self.beginButton.preventRepeatedClicks()
        presentQrScanner()
    }

    private func presentQrScanner() {
        let scanner = QRScannerViewController(nibName: "QrScannerView", bundle: nil)
        scanner.modalPresentationStyle = .fullScreen
        scanner.setQrListener(listener: self)
        present(scanner, animated: true)
    }

    // Strong reference for the helper — the SDK retains the client through the
    // helper, but the helper itself is held here for the duration of the session.
    private func startBuiltInUIVerification(url: String) {
        PingOneVerifyHelper.initialize(with: url, rootViewController: self) { [weak self] helper, clientBuilderError in
            guard let self else { return }
            if let clientBuilderError = clientBuilderError {
                logerror(clientBuilderError.localizedDescription ?? "")
                let alertController = UIAlertController(
                    title: "Client Builder Error",
                    message: clientBuilderError.localizedDescription,
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default))
                DispatchQueue.main.async {
                    self.spinnerOverlay.isHidden = true
                    self.spinner.stopAnimating()
                    self.present(alertController, animated: true)
                }
                return
            }
            guard let helper = helper else { return }
            DispatchQueue.main.async { [weak self] in
                self?.spinnerOverlay.isHidden = true
                self?.spinner.stopAnimating()
            }
            helper.start()
        }
    }

}

// MARK: - QrScannerListener

extension ViewController: QrScannerListener {
    func onQrScanned(viewController: UIViewController, qrString: String) {
        DispatchQueue.main.async {
            viewController.dismiss(animated: false) {
                self.spinnerOverlay.isHidden = false
                self.spinner.startAnimating()
                self.startBuiltInUIVerification(url: qrString)
            }
        }
    }

    func onQrScannerCanceled(viewController: UIViewController) {
        DispatchQueue.main.async { viewController.dismiss(animated: false) }
    }
}

