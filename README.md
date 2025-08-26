# PingOne Verify SDK for iOS


PingOneVerify iOS SDK provides a secure interface for an iOS app to use the PingOne Verify service for validating a user's identity. The SDK also parses the responses received from the service for different operations and forwards the same to the app via callbacks.


### Running the Sample App


[Download the Sample App](https://github.com/pingidentity/pingone-verify-mobile-sdk-ios).


### Prerequisites

* Xcode 12 or greater
* iOS 13 or greater

### Set Up and Clone or Download

The sample app cannot run on a simulator and works only on a device, because the app requires the camera to capture a selfie and the related user ID documents.


1. Ensure your Xcode is set up with a provisioning profile and a signing certificate to be able to install the app on a device. See the Apple Xcode document [Run an app on a device](https://help.apple.com/xcode/mac/current/#/dev5a825a1ca) for more information.


2. Clone or download the [PingOne Verify SDK for iOS sample code](https://github.com/pingidentity/pingone-verify-mobile-sdk-ios) to your computer and open `PingOneVerify.xcodeproj` located in the `PingOneVerify_iOS` directory.


You will find all other XCFramework dependencies required for PingOne Verify in the `PingOneVerify_iOS/common` directory.

Also all common dependencies required for PingOne Verify in the `PingOneVerify_iOS/common` directory.
 

3. To run the sample app, select the scheme `PingOneVerify_iOS` --> , and click **Run**.

### Integrating PingOne Verify SDK with Your App

PingOneVerify iOS SDK provides a secure interface for an iOS app to use the PingOne Verify service for validating a user's identity. The SDK also parses the responses received from the service for different operations and forwards the same to the app via callbacks.

### Getting started

Add the dependencies needed for your application.


The PingOne Verify iOS SDK relies on XCFramework components. You'll need to add these to Xcode for use by your application.


1. Drag and drop the following components from the `SDK/Verify` folder to the section `Frameworks`, `Libraries`, and `Embedded Content` in Xcode:


    * PingOneVerify.xcframework
    
    * BlinkID.xcframework
    
    * VoiceSdk.xcframework
    
    * NeoInterfaces.xcframework
    
    * LanguagePackProvider.xcframework
    
    * IDLiveFaceIAD.xcframework
    
    * IDLiveFaceDetection.xcframework
    
    * IDLiveFaceCamera.xcframework
    
    * GeoLocationProvider.xcframework
    
2. Right click from your project folder and select **Add Files to (your project name)**.

## ⚠️ IMPORTANT: Using Wallet and Verify SDKs in the Same Application

When integrating both the Wallet SDK and Verify SDK into a single application, note that they share common dependencies located in the SDK/Common directory. These shared modules contain utilities and components required by both SDKs.

### Dependencies Configuration

- If using **only the Wallet SDK** → include `Wallet/SDK/Common`
- If using **only the Verify SDK** → include `Verify/SDK/Common`
- If using **both Wallet and Verify** → include inly once instance of `SDK/Common` (preferably from `Wallet/SDK/Common`)

** ⚠️ DO NOT INCLUDE BOTH `Wallet/SDK/Common` & `Verify/SDK/Common` in your project**

Including multiple copies of SDK/Common can result in:

  - Build time errors (e.g. duplicate symbols)
  - Runtime crashes due to conflicting modules
  - Increased binary size due to unnecessary duplication

3. Add `import PingOneVerify` to the top of the Swift file where the SDK is initialized

### Initializing PingOneVerifyClient


1. Import `PingOneVerify_iOS` in your desired ViewController (It must **extend UIViewController**)

```
import PingOneVerify_iOS

```

2. Extend [DocumentSubmissionListener](#documentsubmissionlistener-callbacks) protocol and its functions


```
class YourViewController: UIViewController, DocumentSubmissionListener {

    func onDocumentSubmitted(response: DocumentSubmissionResponse) {
        // Callback when document is successfully submitted
    }

    func onSubmissionComplete(status: DocumentSubmissionStatus) {
        // Callback when verification transaction is completed
    }

    func onSubmissionError(error: DocumentSubmissionError) {
    // Callback when there is an error during submission
    }

}

```

3. Instantiate a `PingOneVerifyClient.Builder` and set its `listener` and `rootViewController` **(Required)**


```
PingOneVerifyClient.Builder()
    .setListener(self)
    .setRootViewController(self)

```

4. Optionally, you can set an explicit **qrString** using the `PingOneVerifyClient.Builder`


```
PingOneVerifyClient.Builder()
    .setListener(self)
    .setRootViewController(self)
    .setQrString(qrString: "https://api.pingone.com...")

```

5. Optionally, you can set a [Selfie Capture Settings](#selfiecapturesettings) with your preference using the `PingOneVerifyClient.Builder`.


```
// Default is 45 seconds for captureTime and true for shouldCaptureAfterTimeout
let selfieCaptureSettings = SelfieCaptureSettings(captureTime: 15, shouldCaptureAfterTimeout: false)
PingOneVerifyClient.Builder()
    .setListener(self)
    .setRootViewController(self)
    .setDocumentCaptureSettings(documentCaptureSettings: [selfieCaptureSettings])

```

6. Start Verification Process

```
PingOneVerifyClient.Builder()
    .setListener(self)
    .setRootViewController(self)
    .startVerification { pingOneVerifyClient, clientBuilderError in
        if let pingOneVerifyClient = pingOneVerifyClient {
            // Handle pingOneVerifyClient
        } else if let clientBuilderError = clientBuilderError {
            // Handle builderError
        }
    }

```

### DocumentSubmissionListener Callbacks



1. `onDocumentSubmitted(response: DocumentSubmissionResponse)`


    * Called whenever a document is successfully submitted.
    * Appropriate [DocumentSubmissionResponse](#documentsubmissionresponse) is returned
```
func onDocumentSubmitted(response: DocumentSubmissionResponse) {
    print("The document status is \(response.documentStatus)")
    print("The document submission status is \(response.documentSubmissionStatus)")
        
    guard let documents = response.document else { return }
    for (key, value) in documents {
        print("\(key): \(value)")
    }
}

```

2. `onSubmissionComplete(status: DocumentSubmissionStatus)`


    * Called when all required documents have been submitted for a transaction.
    * [DocumentSubmissionStatus](#documentsubmissionstatus) will always be `.completed`
```
func onSubmissionComplete(status: DocumentSubmissionStatus) {
    // present a basic alert to indicate completion
    let alertController = UIAlertController(title: "Document Submission Complete", message: "All documents have been successfully submitted", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Okay", style: .default))
    DispatchQueue.main.async {
        self.present(alertController, animated: true)
    }
}

```

3. `onSubmissionError(error: DocumentSubmissionError)`


    * Called when error occurs during SDK flow.
    * Appropriate [DocumentSubmissionError](#documentsubmissionerror) is returned
```
func onSubmissionError(error: DocumentSubmissionError) {
    print(error.localizedDescription)
}

```


### Class Reference

### DocumentSubmissionResponse

`DocumentSubmissionResponse` object holds information pertaining to the document that was successfully submitted to the ID Verification service.


```
@objc public class DocumentSubmissionResponse: NSObject, Codable {
    public var documentStatus: [String: DocumentStatus]
    public var documentSubmissionStatus: DocumentSubmissionStatus
    public var document: [String: String]
    public var createdAt: String // Timestamp of when transaction was created
    public var updatedAt: String // Timestamp of when transaction was last updated
    public var expiresAt: String // Timestamp of when transaction expires

    public func getDocumentStatus() -> [String: DocumentStatus]
    public func getDocumentSubmissionStatus() -> DocumentSubmissionStatus
    public func getDocument() -> [String: String]
    public func getCreatedAt() -> String
    public func getUpdatedAt() -> String
    public func getExpiresAt() -> String
}

```

`documentStatus` dictionary shows the status of each document requested. For example, if the requested documents for a certain transaction are the following:

* Email

* Phone

* Selfie

and the callback `onDocumentSubmitted(response: DocumentSubmissionResponse` was fired after submitting `Email`, the `documentStatus` property will look like this:

```
["Email": .PROCESSED, "Phone": .REQUIRED, "Selfie", .REQUIRED]

```

The list of `DocumentStatus` states can be found in [DocumentStatus](#documentstatus)


`documentSubmissionStatus` property shows the status of the entire verification transaction. Detailed information regarding `DocumentSubmissionStatus` can be found in [DocumentSubmissionStatus](#documentsubmissionstatus)


`document` dictionary holds information about the document that was just submitted to the ID Verification service. **Only applicable keys** are populated in the `document` dictionary


Data model of `document`


| Key | Description |
| --- | --- |
| `frontImage` | Base64 encoded string of the front image of a document |
| `backImage` | Base64 encoded string of the back image of a document |
| `barcode` | Barcode Data found on the document |
| `mrzData` | MRZData found on passport and other relevant document |
| `firstName` | User's first name as shown on the document |
| `middleName` | User's middle name as shown on the document |
| `lastName` | User's last name as shown on the document |
| `fullName` | User's full name |
| `additionalNameInfo` | Additional name info about the user |
| `addressStreet` | User's street address as shown on the document |
| `addressCity` | User's residence city as shown on the document |
| `addressState` | User's residence state as shown on the document |
| `addressZip` | User's ZIP Code as shown on the document |
| `country` | User's residence country as shown on the document |
| `sex` | User's sex as shown on the document |
| `dateOfBirth` | User's date of birth as shown on the document |
| `placeOfBirth` | User's place of birth as shown on the document |
| `nationality` | User's nationality as shown on the document |
| `maritalStatus` | User's marital status as shown on the document |
| `race` | User's race as shown on the document |
| `religion` | User's religion as shown on the document |
| `residentialStatus` | User's residential status as shown on the document |
| `documentNumber` | Document number as shown on the document |
| `documentAdditionalNumber` | Additional document number as shown on the document |
| `personalIdNumber` | Personal Id number as shown on the document |
| `dateOfIssue` | Date of issuance of the document |
| `dateOfExpiry` | Date of expiration of the document |
| `issuingAuthority` | Issuing authority of the document |
| `employer` | Employer as shown on the document |
| `profession` | Profession as shown on the document |


### DocumentStatus

An enum describing the status of a particular document


```
@objc public enum DocumentStatus {
    case REQUIRED // document is required
    case OPTIONAL // document is optional; user may choose to skip
    case COLLECTED // document has been collected
    case PROCESSED // document has been processed
    case SKIPPED // document is skipped by user's choice
}

```

### DocumentSubmissionStatus

An enum describing the status of the verification transaction

```
@objc public enum DocumentSubmissionStatus {
    case not_started // transaction has not been initiated
    case started // transaction has been initiated, but not completed
    case process // transcation is being processed
    case completed // transaction has been processed and is completed
}

```

### SelfieCaptureSettings

A configurable object to customize selfie capture experience

```
@objc public class SelfieCaptureSettings {
    public let captureTime: TimeInterval // selfie capture time (default is 45 seconds)
    public let shouldCaptureAfterTimeout: Bool // whether user should be able to capture selfie after timeout (default is true)
    public var optional: Bool // whether user can decide to skip selfie capture (default is false)
}

```

### PingOne Verify SDK Errors
### ClientBuilderError
`ClientBuilderError` is returned when *PingOneVerify SDK* is initialized **incorrectly**. It subclasses `BuilderError` and `QRError` and is returned during `Builder.startVerification()`


### BuilderError

| Error | Description |
| --- | --- |
| `.missingRootViewController` | RootViewController was not set using `.setRootViewController(viewController: UIViewController)` in the builder |
| `.missingDocumentSubmissionListener` | `DocumentSubmissionListener` was not set using `.setDocumentSubmissionListener(listener: DocumentSubmissionListener)` in the builder |


### QRError

| Error | Description |
| --- | --- |
| `.invalidQR` | Not a valid PingOne QR Code |
| `.unableToParse` | Unable to parse QR Code |
| `.missingQueryItems` | QR Code is missing important query items required to start transaction |
| `.missingVerificationCode` | QR Code is missing verification code |
| `.missingTransactionId` | QR Code is missing transactionId |


### DocumentSubmissionError




| Error | Description |
| --- | --- |
| `.initiateDocumentTransactionError` | Error when initiating a transaction |
| `.submissionError` | Error when submitting a document |
| `.noDocumentToSubmitError` | No more documents to submit |
| `.missingDocumentType` | Document type is missing |
| `.invalidKeyMap` | A valid key map for the document does not exist |
| `.documentCaptureError` | Error when capturing the data |
| `.documentSubmissionTimeoutError` | Document Submission has expired |
| `.missingOTPDestination` | OTP Destination is missing |
| `.failedOTP` | OTP failed with invalid code |



### UI Customization

###  UI Customization for PingOne Verify

###  UIAppearanceSettings

`UIAppearanceSettings` instance allows you to customize the SDK's user interface during run time.

```swift
    @objc public class UIAppearanceSettings: NSObject {
        private var logoImage: UIImage?
        private var backgroundColor: UIColor?
        private var bodyTextColor: UIColor?
        private var headingTextColor: UIColor?
        private var navigationBarColor: UIColor?
        private var navigationBarTextColor: UIColor?
        private var iconTintColor: UIColor?
        private var solidButtonAppearance: ButtonAppearance?
        private var borderedButtonAppearance: ButtonAppearance?
}
```
| Method                                                                                     | Description                         |
|--------------------------------------------------------------------------------------------|-------------------------------------|
| `setLogoImage(_ image: UIImage) -> UIAppearanceSetting`                                    | Set logo image that is shown at the center of the navigation bar |
| `setBackgroundColor(_ color: UIColor) -> UIAppearanceSetting`                              | Set application background color    |
| `setBodyTextColor(_ color: UIColor) -> UIAppearanceSetting`                                | Set body text color                 |
| `setHeadingTextColor(_ color: UIColor) -> UIAppearanceSetting`                             | Set heading text color              |
| `setNavigationBarColor(_ color: UIColor) -> UIAppearanceSetting`                           | Set navigation bar background color |
| `setNavigationBarTextColor(_ color: UIColor) -> UIAppearanceSetting`                       | Set navigation bar text color       |
| `setIconTintColor(_ color: UIColor) -> UIAppearanceSetting`                                | Set icon tint color                 |
| `setSolidButtonAppearance(_ buttonAppearance: ButtonAppearance) -> UIAppearanceSettings`   | Set solid button appearance         |
| `setBorderedButtonAppearance(_ buttonAppearance: ButtonAppearance) -> UIAppearanceSettings`| Set bordered button appearance      |

Example usage:

```swift
    private func getUiAppearanceSettings() -> UIAppearanceSettings {
        let solidButtonAppearance = ButtonAppearance(backgroundColor: .red, textColor: .white, borderColor: .red)
        let borderedButtonAppearance = ButtonAppearance(backgroundColor: .clear, textColor: .red, borderColor: .red)
        
        return UIAppearanceSettings()
            .setSolidButtonAppearance(solidButtonAppearance)
            .setBorderedButtonAppearance(borderedButtonAppearance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uiAppearanceSetting = self.getUiAppearanceSettings()
        
        PingOneVerifyClient.Builder(isOverridingAssets: false)
        .setListener(self)
        .setRootViewController(self)
        .setUIAppearanceSetting(uiAppearanceSetting)
        .startVerification { pingOneVerifyClient, clientBuilderError in
            if let pingOneVerifyClient = pingOneVerifyClient {
                // Handle pingOneVerifyClient
            } else if let clientBuilderError = clientBuilderError {
                // Handle builderError
            }
        }
    }
```
###  UI Customization

### Customizing icon tint color
If using custom image resources, set `PingOneVerifyClient.Builder(isOverridingAssets: Bool)` to `true`. When the `isOverridingAssets` flag is `true`, the icon tint color is not applied to the custom images.

If `PingOneVerifyClient.Builder(isOverridingAssets: Bool)` is set to `false`, the icon tint color is automatically applied to all the icon images.

### Customizing image resource
You can customize these images:

| Asset Name  | Description                                                            | 
|-------------|------------------------------------------------------------------------|
| idv_logo    | Logo image that appears at the center of the navigation bar            |
|idv_gov_id   | Image that is shown when government id is requested                    |                      
| idv_selfie  | Image that is shown when selfie is requested                           |
| idv_phone   | Image that is shown when phone number verification is requestede       |
| idv_email   | Image that is shown when email verification is requested               |
| idv_cancel  | mage that is used for cancel button at top left of the navigation bar  |

To customize an image resource:

1. Include your custom image with the same name in the app asset folder

### Customizing color resource
You can customize the following color resources:

- navigation color
- button color
- button background color
- button text color
- button border color
- application background color
- heading text color
- body text color

To customize:

 1. Pass a custom [UIAppearanceSettings](https://apidocs.pingidentity.com/pingone/native-sdks/v1/api/#uiappearancesettings) instance in the `PingOneVerifyClient.Builder`.

 2. Use [Branding](https://apidocs.pingidentity.com/pingone/platform/v1/api/#branding) from the PingOne platform API.

 3. Use **Branding & Themes** tab found in PingOne Admin Console -> Experiences -> Branding & Themes as described in [Branding and themes](https://docs.pingidentity.com/pingone/user_experience/p1_branding_themes.html).

  [UIAppearanceSettings](https://apidocs.pingidentity.com/pingone/native-sdks/v1/api/#uiappearancesettings) **always has higher priority** than [Branding and themes](https://docs.pingidentity.com/pingone/user_experience/p1_branding_themes.html).

 Thus, if both [UIAppearanceSettings](https://apidocs.pingidentity.com/pingone/native-sdks/v1/api/#uiappearancesettings) and [Branding and themes](https://docs.pingidentity.com/pingone/user_experience/p1_branding_themes.html) are used, the configuaration specified in [UIAppearanceSettings](https://apidocs.pingidentity.com/pingone/native-sdks/v1/api/#uiappearancesettings) is shown.
 
 ### Customizing localization
 For localization and messages, you can replace the values found in [PingOneVerifyLocalizable.strings](https://github.com/pingidentity/pingone-verify-mobile-sdk-ios/blob/master/Sample%20Code/PingOne%20Verify/PingOne%20Verify/PingOneVerifyLocalizable.strings).
 
 ## UI Customization from PingOne Admin Console
 
 You can customize items such as:

- logo
- navigation color
- button color
- button background
- button text
- application background
- heading text
- body text
 
 To customize:
 
 - Use [Branding](https://apidocs.pingidentity.com/pingone/platform/v1/api/#branding) from the PingOne platform API.
 - Use **Branding & Themes** tab found in *PingOne Admin Console -> Experiences -> Branding & Themes* as described in [Branding and themes](https://docs.pingidentity.com/pingone/user_experience/p1_branding_themes.html).
 
 For Localization, use the `Localizable.strings` file to modify.




### Verify Policy



PingOne Verify Native SDK utilizes Verify Policies. You can apply policies two ways:


* Use [Verify Policies](https://apidocs.pingidentity.com/pingone/platform/v1/api/#verify-policies) from the PingOne platform API.


* Use **Policies** tab found in *PingOne Admin Console -> PingOne Verify -> Policies* to customize verify policy for a particular environment.
