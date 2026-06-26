//
//  PingOneVerifyHelper.swift
//  PingOneVerify
//
//  Built-in UI driver for a PingOneVerifyClient transaction.
//  Conforms to VerifyTransactionCoordinatorDelegate and translates each
//  callback into presenter / view-controller calls on the SDK's nav stack.
//
//  Integrators call PingOneVerifyHelper.initialize(with:rootViewController:completionHandler:)
//  to get a configured helper, then call helper.start() to present the UI.
//

import Foundation
import UIKit
import CoreLocation

/// Drives the SDK's built-in UI for a PingOne Verify transaction.
///
/// Use ``initialize(with:rootViewController:completionHandler:)`` to build a helper
/// (it resolves the URL, wires the client, and sets the coordinator delegate for you),
/// then call `start()` on the result.
///
/// ## Example
/// ```swift
/// PingOneVerifyHelper.initialize(with: scannedUrl, rootViewController: self) { helper, error in
///     helper?.start()
/// }
/// ```
public class PingOneVerifyHelper: NSObject {

    // MARK: - State

    internal let pingOneNavController: UINavigationController
    private(set) public weak var rootViewController: UIViewController?

    internal var client: PingOneVerifyClient!
    private var abandonmentObserver: NSObjectProtocol?

    internal var documentCapturePresenter: DocumentCaptureContract = DocumentCapturePresenter()
    private var appTheme: AppThemeResponse?

    let fetchConfigGroup = DispatchGroup()

    /// Builds a ``PingOneVerifyHelper`` ready to drive verification.
    ///
    /// Resolves the verification URL, configures the underlying ``PingOneVerifyClient``,
    /// wires the helper as its coordinator delegate, and returns it via the completion handler.
    /// Call `start()` on the returned helper to present the SDK's UI.
    ///
    /// - Parameters:
    ///   - verificationUrl: The QR/deep-link string for this transaction.
    ///   - rootViewController: The view controller that will present the SDK navigation stack.
    ///   - completionHandler: Called with a ready helper on success, or a ``ClientBuilderError`` on failure.
    public static func initialize(with verificationUrl: String,
                                  rootViewController: UIViewController,
                                  completionHandler: @escaping (PingOneVerifyHelper?, ClientBuilderError?) -> Void) {
        let helper = PingOneVerifyHelper(rootViewController: rootViewController)

        // To wait for both language pack and AppTheme response.
        // This pattern is not required if overriding the UI locally and not using Themes or Branding from PingOne.
        helper.fetchConfigGroup.enter()
        helper.fetchConfigGroup.enter()
        
        PingOneVerifyClient.Builder(verificationUrl: verificationUrl, coordinatorDelegate: helper)
            .build { client, clientBuilderError in
                if let clientBuilderError = clientBuilderError {
                    logerror(clientBuilderError.localizedDescription ?? "")
                    completionHandler(nil, clientBuilderError)
                    return
                }
                guard let client = client else {
                    completionHandler(nil, ClientBuilderError(builderError: .unknownError))
                    return
                }
                helper.client = client
                completionHandler(helper, nil)
            }
    }

    // MARK: - Init

    /// Creates a built-in UI driver.
    ///
    /// Prefer ``initialize(with:rootViewController:completionHandler:)`` — it wires the
    /// underlying client and delegate for you. Use this initializer only if you need to
    /// build the client manually.
    ///
    /// - Parameter rootViewController: The view controller from which the SDK's navigation stack is presented.
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.pingOneNavController = PingOneNavController(
            nibName: "PingOneNavController",
            bundle: Bundle(for: PingOneVerifyHelper.self))
        self.pingOneNavController.modalPresentationStyle = .overCurrentContext

        super.init()

        if let pingOneNav = pingOneNavController as? PingOneNavController {
            pingOneNav.verifyHelper = self
        }
        
    }

    deinit {
        print("🗑️ PingOneVerifyHelper deallocated successfully.")
    }

    /// Presents the navigation stack, concurrently fetches the app theme and language pack,
    /// and starts the underlying ``PingOneVerifyClient`` once both fetches complete.
    public func start() {
        guard let rootViewController = rootViewController else {
            logerror("PingOneVerifyHelper.start() called without a rootViewController")
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            rootViewController.present(self.pingOneNavController, animated: false)
        }
        
        DispatchQueue.global().async {
            self.fetchConfigGroup.wait()
            self.startVerification()
        }
    }

    internal func applyTheme(_ appTheme: AppThemeResponse) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.appTheme = appTheme
            BaseViewController.appTheme = appTheme
            BaseView.updateAppearance(with: appTheme) { [weak self] updatedTheme in
                guard let self = self else { return }
                self.appTheme = updatedTheme
            }
        }
    }

    private func startVerification() {
        addAbandonmentObserver()
        client.startVerification()
    }

    // MARK: - Navigation dismissal

    internal func dismissNavigationController(completion: (() -> Void)? = nil) {
        removeAbandonmentObserver()
        client.endVerification()
        DocumentSubmissionTimer.shared.reset()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let nav = self.pingOneNavController as? PingOneNavController {
                nav.verifyHelper = nil
            }
            self.pingOneNavController.dismiss(animated: true, completion: completion)
        }
    }

    // MARK: - Abandonment observer

    private func addAbandonmentObserver() {
        abandonmentObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(PingOneVerifyNotification.CANCELED_NOTIFICATION_CENTER_KEY),
            object: nil, queue: nil) { [weak self] notification in
                let documentType = notification.object as? DocumentClass
                self?.handleAbandon(documentType: documentType)
        }
    }

    private func removeAbandonmentObserver() {
        if let observer = abandonmentObserver {
            NotificationCenter.default.removeObserver(observer)
            abandonmentObserver = nil
        }
    }

    private func handleAbandon(documentType: DocumentClass?) {
        client.addCancelledAppEvent(documentType: documentType ?? .OTHER)
        dismissNavigationController()
    }
}
