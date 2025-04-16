# UI Customization

##  UI Customization for PingOne Verify

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
 




