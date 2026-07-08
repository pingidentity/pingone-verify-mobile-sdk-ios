# PingOne Verify iOS SDK

PingOne Verify is an identity verification service that supports the collection and authentication of identity evidence, including government-issued IDs, selfies, email/phone OTPs, and geolocation. This SDK functions as the collection client for the verification flow, capturing user evidence and performing quality checks to ensure documents and images meet the required standards before they are submitted for verification.

---

## Contents

1. [Components](#components)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Migration Guide](#migration-guide)
5. [Class Reference](#class-reference)

---

## Components

![Architecture](Flow%20Diagrams/Architecture.svg)

| Component | Description |
|-----------|-------------|
| **Native Mobile Application** | The consuming application that integrates the SDK. It initiates verification flows by invoking public client methods and is responsible for integrating and customizing the open-source UI module. |
| **verify-ui** | Open-source UI module that provides the instructional and interactive screens necessary for the various verification capture flows. |
| **verify-core** | The central coordination layer. It orchestrates all necessary flows between the UI and capture components, manages secure data transmission to the backend service, and ensures successful execution of the overall transaction logic. |
| **ID Capture Module** | Integrates with specialized ID scanning SDKs to capture images and extract data from government identity documents. |
| **Selfie Capture Module** | Manages the facial image capture process, performs real-time quality checks on live frames, and executes liveness detection to mitigate injection attacks. |
| **verify-transaction-coordinator** | Interface implemented within the core module; utilized by the UI to execute specific actions (e.g., submit data). |
| **verify-transaction-coordinator-delegate** | Interface implemented by the UI; utilized by the core module to notify the UI to perform actions based on instructions received from the backend service. |
| **Backend Service** | PingOne Verify services hosted in the PingOne multi-tenant SaaS platform. Provides data collection and transaction state management, enabling a "backend-driven UI" flow alongside verify-core. |

---

## Integration Flow Diagrams

The diagrams below show the message flow between your UI layer (`verify-ui`), the delegate you implement (`verify-coordinator-delegate`), the coordinator API (`verify-coordinator`), and the SDK core (`verify-core`) for each capture type.

### Government ID Capture

Scans a government-issued document (passport, driver licence, or national ID) and submits it for server-side verification. On quality failures, the SDK requests a retry up to the number of attempts configured in your verify policy.

![Government ID Capture](Flow%20Diagrams/GovernmentId.png)

---

### Selfie Capture

Captures a live selfie for liveness detection and face-match verification. If the selfie step is marked optional in your verify policy, the UI can skip it entirely. On quality failures, the SDK requests a retry.

![Selfie Capture](Flow%20Diagrams/Selfie.png)

---

### Email OTP Verification

Collects the user's email address, sends a one-time passcode to that address, and validates it. The user can request a resend at any time; the SDK refreshes the OTP session and restarts the expiry countdown automatically.

![Email OTP Verification](Flow%20Diagrams/Email.png)

---

### Phone OTP Verification

Same flow as email OTP but the one-time passcode is delivered via SMS. The user enters their phone number, receives a code, and submits it.

![Phone OTP Verification](Flow%20Diagrams/Phone.png)

---

### Geolocation Capture

Requests the device's current location. If the user grants permission the coordinates are captured and submitted immediately. If permission is denied the SDK surfaces an error; the UI should display a rationale and a button so the user can grant permission from Settings and retry.

![Geolocation Capture](Flow%20Diagrams/Geolocation.png)

---

## Prerequisites

- Xcode 15 or later
- iOS 16 or later
- A physical device (camera is required; simulator is not supported for capture steps)

---

## Installation

### Built-in UI (use open-source `VerifyUI` source)

1. Copy the `VerifyUI/` folder from the sample repository into the App project and add all its source files to the app target. `VerifyUI` depends on `PingOneVerify` and `NeoInterfaces`.

2. Link the following XCFrameworks from the `Common` folder in your target's **Frameworks, Libraries, and Embedded Content**:
   - `PingOneVerify.xcframework` *(required)*
   - `NeoInterfaces.xcframework` *(required)*
   - All other XCFrameworks in the `Common` folder *(required — crypto, JOSE, etc.)*
   - `IdCaptureProvider.xcframework` *(required for government ID / passport / driver licence scanning)*
   - `SelfieCaptureProvider.xcframework` *(required for selfie capture)*
   - `GeoLocationProvider.xcframework` *(optional — only if your policy requires geolocation)*

> **Language pack:** Built into `PingOneVerify.xcframework` — no separate framework needed. The SDK fetches the remote language pack automatically during `helper.start()`. Use `Builder.setLanguageCode(_:)` to override the device locale.

3. No `import VerifyUI` needed — the source is compiled directly into your target.

---

## Quick Start — Built-in UI

The SDK no longer ships a built-in QR scanner — the SDK obtains the verification URL but the sample application contains a QR scanner that can be reused.
`Builder.build()` returns the client and concurrently fetches the app theme and language pack — the verification flow begins only after both fetches complete. `helper.start()` presents the navigation stack. 


```swift
class ViewController: UIViewController {

func start(url: String) {
    PingOneVerifyHelper.initialize(with: url, rootViewController: self) { [weak self] helper, error in
        guard let self, let helper = helper else {
            print("Builder error: \(error?.localizedDescription ?? "")")
            return
        }

        helper.start()
    }
}

}
```

`PingOneVerifyHelper.initialize` configures the underlying `PingOneVerifyClient` and wires the helper as the coordinator delegate. Keep a strong reference to the helper for the lifetime of the session.

---

### Localization

Override any string by replacing its value in `PingOneVerifyLocalizable.strings` inside your app bundle. Local overrides always take precedence over the remote language pack.

---

## Migration Guide

You can refer to the [migration guide](MIGRATION.md).

---

## Class Reference

You can refer to the [class reference](Class%20Reference.md).

---

