# VerifyTransactionCoordinator / VerifyTransactionCoordinatorDelegate — iOS Public API Reference

Two-way contract between the verification UI and the SDK core.

- **`VerifyTransactionCoordinator`** — UI calls these on core to submit data and drive the flow.
- **`VerifyTransactionCoordinatorDelegate`** — core calls these on the UI to instruct what to show next.

---

## `VerifyTransactionCoordinator`

### Document submission

| Method | Signature | Description |
|--------|-----------|-------------|
| Submit email | `submitEmail(_ email: String)` | Submits an email address for OTP verification. |
| Submit phone | `submitPhone(_ phone: String)` | Submits a phone number for OTP verification 
| Submit selfie | `submitSelfie(_ result: SelfieCaptureResult)` | Submits a captured selfie to PingOne Verify. |
| Submit government ID | `submitGovernmentId(_ result: IdCaptureResult)` | Submits a captured government ID to PingOne Verify. |
| Submit geolocation | `submitGeolocation(latitude: Double, longitude: Double)` | Submits captured geolocation coordinates. |

### OTP

| Method | Signature | Description |
|--------|-----------|-------------|
| Submit OTP | `submitOtp(passcode: String, otpType: DocumentClass)` | Submits the one-time passcode entered by the user. `otpType` must be `.EMAIL` or `.PHONE`. |
| Resend OTP | `resendOtp(for documentType: DocumentClass)` | Requests a new OTP delivery for the given document type. |

### Capture launch

| Method | Signature | Description |
|--------|-----------|-------------|
| Launch selfie capture | `captureSelfie(from navigationController: UINavigationController)` | Launches the selfie capture flow. Requires the selfie provider module. |
| Launch ID capture | `captureGovernmentId(from navigationController: UINavigationController)` | Launches the ID capture flow. Requires the ID capture provider module. |
| Capture geolocation | `captureGeolocation()` | Asks the geolocation provider to request the device's current location. |

### Flow control

| Method | Signature | Description |
|--------|-----------|-------------|
| Skip step | `skipDocument(type: DocumentClass)` | Skips the current optional step. The server must mark the step optional or the call fails. |
| End flow | `endVerification()` | Ends the verification flow and releases observers. |

---

## `VerifyTransactionCoordinatorDelegate`

### Theme and language pack (triggerred before the first `shouldCaptureDocument`)

| Method | Signature | Description |
|--------|-----------|-------------|
| App theme ready | `coordinator(_:didReceiveAppTheme appTheme: AppThemeResponse?, error: Error?)` | Server theme fetched. `appTheme` is non-nil on success; `error` is non-nil on failure. |
| Language pack ready | `coordinator(_:didReceiveLanguagePack languagePackProvider: LanguagePackProviderContract?, error: Error?)` | Language pack fetched. Use `error` (non-nil on failure) to fall back to bundled strings. Fires at `build` completion, before `start()`. |

### Capture lifecycle

| Method | Signature | Description |
|--------|-----------|-------------|
| Should capture | `coordinator(_:shouldCaptureDocument settings: DocumentCaptureSettings)` | Core needs the user to capture a document or provide OTP/geolocation. Read `settings.documentType` to determine the screen to show. |
| Should retry | `coordinator(_:shouldRetryCapture feedback: RetryFeedback, settings: DocumentCaptureSettings)` | The previous submission failed due to the quality issues and the user may retry. |
| Did submit document | `coordinator(_:didSubmitDocument response: DocumentSubmissionResponse)` | Document submitted successfully. |
| Did capture selfie | `coordinator(_:didCaptureSelfie result: SelfieCaptureResult)` | Selfie camera finished. Show preview if desired, then call `submitSelfie(result)` or `captureSelfie(...)` to retake. |
| Did capture ID | `coordinator(_:didCaptureGovernmentId result: IdCaptureResult)` | ID scan finished. Show preview if desired, then call `submitGovernmentId(result)` or `captureGovernmentId(...)` to retake. |
| Did capture geolocation | `coordinator(_:didCaptureGeolocation latitude: Double, longitude: Double)` | Geolocation captured. Optionally show a confirmation, then call `submitGeolocation(...)`. |

### OTP

| Method | Signature | Description |
|--------|-----------|-------------|
| Did submit OTP | `coordinator(_:didSubmitOtp success: Bool)` | OTP verification result. `true` if the passcode was accepted. |
| OTP session updated | `coordinator(_:didUpdateOtpSession settings: OtpCaptureSettings)` | OTP session state changed (e.g. after a resend acknowledgement). Refresh the OTP entry screen with the new state. |

### Completion / failure

| Method | Signature | Description |
|--------|-----------|-------------|
| Did complete | `coordinator(didCompleteSubmission coordinator: VerifyTransactionCoordinator)` | All required documents submitted. Navigate to your completion screen and release your reference to the coordinator. |
| Did fail | `coordinator(_:didFailWith error: DocumentSubmissionError)` | Unrecoverable error. Use `error.getErrorCode()` / `error.getErrorMessage()` for details. |

---

## Data Model

### `DocumentStatus` — Server-reported per-document status

Used as values inside `DocumentSubmissionResponse.documentStatus`.

| Case | Raw value | Description |
|------|-----------|-------------|
| `REQUIRED` | `"REQUIRED"` | Must be collected before the transaction can complete. |
| `OPTIONAL` | `"OPTIONAL"` | May be collected but can be skipped. |
| `COLLECTED` | `"COLLECTED"` | Received by the server. |
| `PROCESSED` | `"PROCESSED"` | Processed by the server. |
| `SKIPPED` | `"SKIPPED"` | Skipped by the user or the SDK. |

### `DocumentSubmissionStatus` — Overall collection status

Returned in `DocumentSubmissionResponse.documentSubmissionStatus`.

| Case | Raw value | Description |
|------|-----------|-------------|
| `NOT_STARTED` | `"NOT_STARTED"` | Document collection has not yet begun. |
| `STARTED` | `"STARTED"` | Document collection is in progress. |
| `COMPLETED` | `"COMPLETED"` | All required documents have been collected. |
| `PROCESS` | `"PROCESS"` | Documents are being processed by the server. |

### `OtpStatus` — OTP delivery / verification status (inside `OtpSession`)

| Case | Raw value | Description |
|------|-----------|-------------|
| `REQUESTED` | `"REQUESTED"` | OTP requested; delivery has not yet started. |
| `IN_PROGRESS` | `"IN_PROGRESS"` | OTP delivery in progress. |
| `OTP_SENT` | `"OTP_SENT"` | OTP delivered to the user. |
| `SUCCESS` | `"SUCCESS"` | Delivery and verification successful. |
| `FAIL` | `"FAIL"` | Delivery or verification failed; not retryable. |
| `OTP_RETRYABLE` | `"OTP_RETRYABLE"` | Delivery failed; the user may request a new code. |
| `OTP_VERIFIED` | `"OTP_VERIFIED"` | User successfully verified the OTP. |

### `SelfieCaptureResult`

Returned by `didCaptureSelfie` and consumed by `submitSelfie`.

| Field | Type | Description |
|-------|------|-------------|
| `selfie` | `let selfie: String` | Base64-encoded JPEG selfie image. |
| `iadPayload` | `let iadPayload: String?` | Base64-encoded liveness payload from the Selfie Capture SDK, or `nil` if unavailable. |

### `IdCaptureResult`

Returned by `didCaptureGovernmentId` and consumed by `submitGovernmentId`.

| Field | Type | Description |
|-------|------|-------------|
| `documentData` | `let documentData: [String: String]` | Key-value map of OCR fields and base64-encoded images extracted from the document. |
| `idType` | `let idType: String` | The scanned document type string (e.g. `"DRIVER_LICENSE"`, `"PASSPORT"`). |

### `DocumentSubmissionResponse`

Server response delivered to `didSubmitDocument`.

| Field | Type | Description |
|-------|------|-------------|
| `document` | `public var document: [String: String]?` | The submitted document data as a key-value dictionary (e.g. `["email": "user@example.com"]`). Used internally to derive the OTP destination for `EMAIL` / `PHONE` flows. |
| `documentStatus` | `public var documentStatus: [String: DocumentStatus]?` | Per-document verification status, keyed by document type string. Values are typed `DocumentStatus` enum cases. |
| `documentSubmissionStatus` | `public var documentSubmissionStatus: DocumentSubmissionStatus?` | Overall status of the document collection session. |
| `createdAt` | `public var createdAt: String?` | ISO 8601 timestamp when the session was created on the server. |
| `updatedAt` | `public var updatedAt: String?` | ISO 8601 timestamp of the most recent server-side update. |
| `expiresAt` | `public var expiresAt: String?` | ISO 8601 timestamp after which the session is no longer valid. |

### `RetryFeedback`

Server feedback for a failed capture, delivered to `shouldRetryCapture`.

| Field | Type | Description |
|-------|------|-------------|
| `code` | `let code: String` | Server error code (e.g. `"QUALITY_CHECK_FAILED"`). |
| `message` | `let message: String` | Human-readable fallback message from the server. |
| `languagePackKey` | `let languagePackKey: String?` | Language-pack key for the localised error string. `nil` when no language-pack key was provided by the server. |

### `DocumentCaptureSettings`

Common base protocol for every capture step. Concrete subtypes — `IdCaptureSettings`, `SelfieCaptureSettings`, `EmailCaptureSettings`, `PhoneCaptureSettings`, `OtpCaptureSettings`, `LocationCaptureSettings` — carry additional fields specific to their step.

| Field | Type | Description |
|-------|------|-------------|
| `documentType` | `DocumentClass` | The data type this step collects. |
| `optional` | `Bool` | When `true`, the user may skip this step. |
| `isRetry` | `Bool` | `true` when this step is a retry of a previously failed attempt. |
| `payloadSize` | `PayloadSize` | Compression level applied to the upload payload. |

### `OtpCaptureSettings` (conforms to `DocumentCaptureSettings`)

Subtype delivered to `shouldCaptureDocument` and `didUpdateOtpSession` for OTP steps.

| Field | Type | Description |
|-------|------|-------------|
| `destination` | `var destination: String` | Email address or phone number to which the OTP was sent. |
| `otpSession` | `var otpSession: OtpSession?` | Typed OTP session state — contains expiry, resend availability, and ticker instances. |
| `otpExpiryTicker` | `var otpExpiryTicker: OtpTicker { get }` | Countdown to OTP expiry. Subscribe to `onTick` / `onExpire`. |
| `resendCooldownTicker` | `var resendCooldownTicker: OtpTicker { get }` | Countdown to when a new OTP delivery may be requested. |
| `requirements` | `var requirements: RequirementsProtocol?` | Server-defined constraints on the destination field. |

### `OtpSession` (embedded in `OtpCaptureSettings.otpSession`)

| Field | Type | Description |
|-------|------|-------------|
| `otpStatus` | `OtpStatus` | Current delivery/verification status (see [OtpStatus](#otpstatus--otp-delivery--verification-status-inside-otpsession)). |
| `expiresAt` | `String?` | ISO 8601 OTP expiry timestamp. |
| `canResend` | `Bool?` | Whether the server permits another OTP delivery. |
| `resendCooldown` | `String?` | Seconds the caller must wait before another resend. |
| `remainingDeliveries` | `Int?` | Number of remaining OTP delivery attempts. |
| `otpLength` | `Int?` | Expected length of the OTP code. |

### `OtpTicker`

Countdown ticker owned by the SDK core; instances are exposed on `OtpCaptureSettings`.

| Member | Type | Description |
|--------|------|-------------|
| `onTick` | `((TimeInterval) -> Void)?` | Fires every second on main with the remaining seconds (clamped at zero). |
| `onExpire` | `(() -> Void)?` | Fires once on main when remaining time reaches zero. |
| `remaining` | `TimeInterval` | Read-only current remaining seconds. |
| `start(expiresAt:)` | `func start(expiresAt: String)` | Starts (or restarts) the ticker, counting down to the given UTC timestamp. Normally driven automatically by the SDK. |
| `stop()` | `func stop()` | Stops the ticker. |

### `AppThemeResponse`

Delivered to `didReceiveAppTheme`.

| Field | Type | Description |
|-------|------|-------------|
| `companyName` | `var companyName: String?` | Configured company name, if any. |
| `template` | `var template: String` | Template identifier (e.g. `"default"`). |
| `defaultTheme` | `var defaultTheme: Bool` | `true` when the server returned the default PingOne theme. |
| `configuration` | `var configuration: ThemeConfig` | Full set of colour, button, and logo configuration values. |

### `VerifyTransaction` (exposed via `currentTransaction`)

Live transaction state read from `coordinator.currentTransaction`.

| Field | Type | Description |
|-------|------|-------------|
| `transactionId` | `String` | Server-assigned transaction identifier. |
| `verificationCode` | `String` | Short code the end user enters/scans to begin the transaction. |
| `environmentId` | `String?` | PingOne environment ID owning the transaction, if provided. |
| `keyVersion` | `String` | API contract version. Currently `"v1"`. |
| `requiredDocuments` | `[String: DocumentStatus]` | Map of document type strings to their current status. |
| `url` | `VerifyApiLinks` | API endpoint links for submit, poll, etc. |

### `DocumentSubmissionError`

Delivered to `didFailWith` on unrecoverable failures.

| Member | Type | Description |
|--------|------|-------------|
| `code` | `public var code: String!` | Machine-readable error code (e.g. `"tx_failed"`, `"doc_timeout"`). |
| `localizedDescription` | `public var localizedDescription: String!` | Human-readable description, suitable for logging. |
| `getErrorCode()` | `func getErrorCode() -> String` | Accessor for `code`. |
| `getErrorMessage()` | `func getErrorMessage() -> String` | Accessor for `localizedDescription`. |

**`SubmissionError` enum cases**: `initiateDocumentTransactionError`, `submissionError`, `noDocumentToSubmitError`, `missingDocumentType`, `invalidKeyMap`, `documentCaptureError`, `documentSubmissionTimoutError`, `missingOtpDestination`, `missingOtp`, `failedOtp`, `transactionError`, `userCanceledError`, `encryptionError`.

## Canonical Flow

```
shouldCapture<X>    Core → UI    (UI shows the capture screen)
capture<X>          UI → Core    (UI launches the capture provider)
didCapture<X>       Core → UI    (UI shows preview / confirm)
submit<X>           UI → Core    (UI shows progress screen)
didSubmitDocument   Core → UI    (UI hides progress, advances)
```

Where `<X>` is one of `GovernmentId`, `Selfie`, `Geolocation`. For email/phone/OTP steps the UI shows a text-entry screen instead of a capture provider and skips the `capture<X>` / `didCapture<X>` legs.

**Progress screen lifecycle**:
- Show after `submit<X>`.
- Hide on `didSubmitDocument`, `didCompleteSubmission`, or the next `shouldCapture<X>`.
