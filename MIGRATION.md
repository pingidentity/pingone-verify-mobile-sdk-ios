# Migration Guide — PingOne Verify iOS SDK v4

This guide covers migrating from the previous SDK (the `PingOneVerifyClient.Builder(isOverridingAssets:)` API with `DocumentSubmissionListener`) to the current SDK.

If you're using the built-in UI, your code change is small — most of the rewrite happens inside the SDK. If you're using a headless / BYOUI integration, expect more delegate method changes.

---

## TL;DR — Code diff for a typical built-in-UI integration

**Before:**

```swift
import UIKit
import PingOneVerify

class ViewController: UIViewController {
    @IBAction func beginVerification() {
        PingOneVerifyClient.Builder(isOverridingAssets: false)
            .setListener(self)
            .setRootViewController(self)
            .setBackActionHandler(self)
            .startVerification { client, error in
                if let error = error {
                    // present error
                }
            }
    }
}

extension ViewController: DocumentSubmissionListener, BackActionListener {
    func onDocumentSubmitted(response: DocumentSubmissionResponse) { /* … */ }
    func onSubmissionComplete(status: DocumentSubmissionStatus) {
        performSegue(withIdentifier: "completed_segue", sender: self)
    }
    func onSubmissionError(error: DocumentSubmissionError) { /* … */ }
    func onBackAction(exitFlow: @escaping (Bool) -> Void) { /* … */ }
}
```

**After:**

```swift
import UIKit
import PingOneVerify

class ViewController: UIViewController {
    @IBAction func beginVerification() {
        // You supply the QR / deep-link URL from your own scanner or backend.
        let verificationUrl = ...

        PingOneVerifyHelper.initialize(with: verificationUrl, rootViewController: self) { helper, error in
            if let error = error {
                // present error
                return
            }
            helper?.start()    // presents nav, fetches theme + lang pack, starts session
        }
    }
}
```

That's it for the built-in UI. The helper:

- Owns the underlying `PingOneVerifyClient` (no more `setListener`).
- Triggers `performSegue(withIdentifier: "completed_segue", sender: nil)` on your `rootViewController` automatically on completion — define that segue in your storyboard.
- On failure, dismisses the SDK navigation stack and then presents an alert with the error message on your `rootViewController`. No code on your side.
- Handles back / cancel internally (no more `BackActionListener`).

> The completion segue is invoked via `UIViewController.performSegue`, so your `rootViewController` must be part of a storyboard hierarchy with a segue named `completed_segue` outgoing from it. If your app isn't storyboard-driven, override `prepare(for:sender:)` or replace the segue mechanism with a custom navigation step.

---

## Removed/Updated APIs

### `PingOneVerifyClient.Builder`

| Removed | Replacement |
|---|---|
| `Builder(isOverridingAssets:)` | `Builder(verificationUrl: String, coordinatorDelegate: VerifyTransactionCoordinatorDelegate)` — the delegate is now part of the init signature, not a setter. |
| `.setRootViewController(_:)` | For built-in UI, use `PingOneVerifyHelper.initialize(with:rootViewController:completionHandler:)`. The Builder no longer needs a view controller. |
| `.setListener(_:)` (`DocumentSubmissionListener`) | Pass a `VerifyTransactionCoordinatorDelegate` to `Builder.init(verificationUrl:coordinatorDelegate:)` instead. |
| `.setQrString(qrString:)` | Pass the URL to `Builder.init(verificationUrl:)` directly. |
| `.setBackActionHandler(_:)` (`BackActionListener`) | Removed. Built-in UI handles back / cancel internally. For custom UI, manage the back action in your own UI and call `coordinator.endVerification()` to tear down state. |
| `.setUIAppearance(_:)` + `UIAppearanceSettings` | Removed. Built-in UI applies the theme configured in the PingOne Admin Console automatically. Override individual assets (logo, icons) by updating the app's asset catalogue (see README → "Custom Image Assets"). |
| `.setLanguagePackProvider(languagePackProvider:)` | Removed as a Builder setter. Language pack fetching is built into core and runs automatically. |
| `.setDocumentCaptureSettings(documentCaptureSettings:)` | Removed. Capture settings are constructed on demand by the SDK from the server's `requirements` payload. Read the `DocumentCaptureSettings` delivered to your `coordinator(_:shouldCaptureDocument:)` callback. |
| `.startVerification(onComplete:)` | `Builder.build(onComplete:)` produces the client, then call `client.start()`. |

### Removed listener protocols

| Removed | Replacement |
|---|---|
| `DocumentSubmissionListener` (`onDocumentSubmitted`, `onSubmissionComplete`, `onSubmissionError`) | `VerifyTransactionCoordinatorDelegate` (`coordinator(_:didSubmitDocument:)`, `coordinator(didCompleteSubmission:)`, `coordinator(_:didFailWith:)`). |
| `DocumentCaptureListener` | Removed entirely. All capture flow goes through `VerifyTransactionCoordinatorDelegate`. |
| `BackActionListener` (`onBackAction`) | Removed. Built-in UI handles back internally. |

### Renamed delegate methods

| Old (`DocumentSubmissionListener`) | New (`VerifyTransactionCoordinatorDelegate`) |
|---|---|
| `onDocumentSubmitted(response:)` | `coordinator(_:didSubmitDocument:)` — same `DocumentSubmissionResponse` payload. |
| `onSubmissionComplete(status:)` | `coordinator(didCompleteSubmission:)` — **note**: the `status:` argument is gone. If you relied on the final `DocumentSubmissionStatus`, read it from the most recent `didSubmitDocument(response:)` callback before the flow completed. |
| `onSubmissionError(error:)` | `coordinator(_:didFailWith:)` — same `DocumentSubmissionError` payload. |

---

## New delegate methods (must be implemented when building custom UI)

`VerifyTransactionCoordinatorDelegate` has no default implementations — all the methods in the interface must be implemented to execute the verification flow. 

- `coordinator(_:didReceiveAppTheme:error:)` — server theme delivered. Apply, or fall back to defaults on error.
- `coordinator(_:didReceiveLanguagePack:error:)` — remote language pack delivered.
- `coordinator(_:shouldCaptureDocument:)` — fires for every capture step. Drive your UI from `settings.documentType`.
- `coordinator(_:didCaptureGovernmentId:)` — show a preview screen, then call `coordinator.submitGovernmentId(_:)`.
- `coordinator(_:didCaptureSelfie:)` — show a preview screen, then call `coordinator.submitSelfie(_:)`.
- `coordinator(_:shouldRetryCapture:settings:)` — server requested a retry. `feedback` is a `RetryFeedback` value.
- `coordinator(_:didCaptureGeolocation:longitude:)` — location coordinates available. Call `coordinator.submitGeolocation(latitude:longitude:)` from here.
- `coordinator(_:didSubmitDocument:)` — document was submitted; update progress.
- `coordinator(_:didSubmitOtp:)` — OTP result. `true` on success; on `false`, show the user the error and let them re-enter (the SDK handles the `OTP_RETRYABLE` / `FAIL` distinction internally — `FAIL` will additionally advance the flow).
- `coordinator(_:didUpdateOtpSession:)` — OTP session updated (e.g. after a resend). Read `settings.otpSession`, `settings.destination`, and the ticker instances directly off `settings`.
- `coordinator(didCompleteSubmission:)` — flow finished successfully.
- `coordinator(_:didFailWith:)` — flow failed.

## Coordinator methods

`VerifyTransactionCoordinator` provides four methods specifically for routing capture through the default provider modules:

- `captureSelfie(from:)` — launches the `SelfieCapture` capture UI.
- `submitSelfie(_:)` — submits a captured `SelfieCaptureResult`.
- `captureGovernmentId(from:)` — launches the `IdCapture` capture UI.
- `submitGovernmentId(_:)` — submits a captured `IdCaptureResult`.

---

## Framework changes

| Framework | Status |
|---|---|
| `PingOneVerify.xcframework` | Required (no change) |
| `NeoInterfaces.xcframework` | Required (no change) |
| `LanguagePackProvider.xcframework` | **Removed.** Delete it from Frameworks, Libraries, and Embedded Content. Language pack support is now built into the `Verify UI` module. |
| `IdCaptureProvider.xcframework` | Depends on `BlinkID` + `BlinkIDUX`. Required for government-ID capture steps. |
| `SelfieCaptureProvider.xcframework` | Depends on `IDLiveFaceCamera`, `IDLiveFaceDetection`, `IDLiveFaceIAD`. Required for selfie steps. |
| `GeoLocationProvider.xcframework` | Optional (unchanged). Required only for geolocation steps. |

See README → "Removing capture providers" for the exact framework lists per feature.

---

## Behaviour changes

### No auto-start; QR scanner is no longer auto-presented

- `client.start()` is explicit — the SDK does not auto-start after `build`.
- The Builder no longer presents its own QR scanner. The previous `Builder(isOverridingAssets: false)` form, with no `setQrString(...)`, would launch a built-in QR scanner; that auto-presentation is gone.
- Developers must supply the Verification URL to `Builder.init(verificationUrl:)`. A `QRScannerViewController` is still shipped in the VerifyUI source (see `PingOneVerifySample/VerifyUI/QrScanner/`)

### Assets no longer ship in the SDK framework

The default images and named colours used by the built-in UI used to live inside `PingOneVerify.xcframework`'s asset catalogue. The framework no longer ships any `Assets.xcassets`. The defaults now live in the VerifyUI source layer (`PingOneVerifySample/Assets.xcassets` in the sample), which is compiled into the app target along with the VerifyUI source.

**What this means for you:**

- If `Builder(isOverridingAssets: false)` was used (the common case — let the SDK bundle supply the images): no action needed since the app target contains the assets now.
- If `Builder(isOverridingAssets: true)` was used and app was overriding the assets with the same name images, assets in the catalogue in VerifyUI can be repalced now. The `isOverridingAssets` flag itself is removed.

---

## Step-by-step migration checklist

1. Replace `PingOneVerifyClient.Builder(isOverridingAssets:).setListener(...).setRootViewController(...).startVerification { ... }` call with `PingOneVerifyHelper.initialize(with:rootViewController:completionHandler:) { helper, error in ... }`. In the completion, check `error` first and present an alert; otherwise call `helper?.start()`.
2. Implementations for `DocumentSubmissionListener`, `BackActionListener`, `DocumentCaptureListener` can be removed. For built-in UI, no new interface implementations are required, it is handled in `PingOneVerifyHelper`.
3. `setUIAppearance` should be removed if it was used. Configure the theme in the PingOne Admin Console, and override individual assets by replacing the illustrations in the app catalogue.  `isOverridingAssets` Builder flag is removed. The SDK framework no longer ships an asset catalogue, all the assets live in the app target.
4. Remove `LanguagePackProvider.xcframework` from your target's linked frameworks.
---
