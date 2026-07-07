//
//  BaseView.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 5/3/22.
//

import Foundation
import UIKit

internal class BaseView: UIView {
    
    static func updateAppearance(with appTheme: AppThemeResponse, callback: ((AppThemeResponse) -> Void)?) {
        DispatchQueue.main.async {
            setBodyTextColorTo(appTheme.configuration.bodyTextColor)
            setHeaderTextColorTo(appTheme.configuration.headingTextColor)
            setBgColorTo(appTheme.configuration.cardColor)
            setCustomMenuButtonColorTo(appTheme.configuration.backgroundColor, textColor: appTheme.configuration.headingTextColor)

            setButtonCornerRadius(DataCaptureConstants.BUTTON_CORNER_RADIUS_NUM)
            setButtonFont(UIFont.systemFont(ofSize: DataCaptureConstants.BUTTON_FONT_SIZE))

            setSolidButtonBackgroundColorTo(appTheme.configuration.solidButtonAppearance.getBackgroundColor())
            setSolidButtonTextColorTo(appTheme.configuration.solidButtonAppearance.getTextColor())

            setBorderedButtonBackgroundColorTo(appTheme.configuration.borderedButtonAppearance.getBackgroundColor())
            setBorderedButtonTextColorTo(appTheme.configuration.borderedButtonAppearance.getTextColor())
            setBorderedButtonBorderColorTo(appTheme.configuration.borderedButtonAppearance.getBorderColor())
            setBorderedButtonBorderWidthTo(DataCaptureConstants.SKIP_BUTTON_BORDER_WIDTH_NUM)

            setPingOneNavAppearanceTo(appTheme.configuration.navigationBarColor, textColor: appTheme.configuration.navigationBarTextColor, barButtonTintColor: appTheme.configuration.navigationBarTextColor)
            setIconTintColorTo(appTheme.configuration.iconTintColor)
            setIconImageViewTintColorTo(iconTintColor: appTheme.configuration.iconTintColor)
            setProcessingColorTo(appTheme.configuration.processingColor)

            updateTextFieldAppearance()
            
            if let logoFromMain = UIImage(named: "idv_logo", in: Bundle.main, compatibleWith: nil) {
                var newAppTheme: AppThemeResponse = appTheme
                setLogoImage(logoFromMain)
                newAppTheme.configuration.logo = ImageLink(image: logoFromMain)
                callback?(newAppTheme)
            } else if appTheme.configuration.logoType == .IMAGE,
                      let logoImage = appTheme.configuration.logo.getImage() {
                setLogoImage(logoImage)
                callback?(appTheme)
            } else {
                loadLogoImageFrom(appTheme.configuration.logo.href) { logoImage in
                    var newAppTheme: AppThemeResponse = appTheme
                    setLogoImage(logoImage)
                    if let logoImage = logoImage {
                        newAppTheme.configuration.logo = ImageLink(image: logoImage)
                    }
                    callback?(newAppTheme)
                }
            }
        }
    }
    
    private static func setBodyTextColorTo(_ color: UIColor) {
        UITextView.appearance(whenContainedInInstancesOf: [BaseView.self]).textColor = color
        UILabel.appearance(whenContainedInInstancesOf: [BaseView.self]).textColor = color
        UITextField.appearance(whenContainedInInstancesOf: [BaseView.self]).textColor = color
    }
    
    private static func setSolidButtonBackgroundColorTo(_ color: UIColor) {
        VerifyButton.appearance().backgroundColor = color
    }
    
    private static func setSolidButtonTextColorTo(_ color: UIColor) {
        VerifyButton.appearance().fontColor = color
    }
    
    private static func setButtonCornerRadius(_ cornerRadius: NSNumber) {
        VerifyButton.appearance().cornerRadius = cornerRadius
        BorderedButton.appearance().cornerRadius = cornerRadius
    }
    
    private static func setButtonFont(_ font: UIFont) {
        VerifyButton.appearance().titleFont = font
        BorderedButton.appearance().titleFont = font
    }
    
    private static func setBorderedButtonBackgroundColorTo(_ color: UIColor) {
        BorderedButton.appearance().backgroundColor = color
    }
    
    private static func setBorderedButtonTextColorTo(_ color: UIColor) {
        BorderedButton.appearance().fontColor = color
    }
    
    private static func setBorderedButtonBorderColorTo(_ color: UIColor) {
        BorderedButton.appearance().borderColor = color
    }
    
    private static func setBorderedButtonBorderWidthTo(_ borderWidth: NSNumber) {
        BorderedButton.appearance().borderWidth = borderWidth
    }
    
    
    private static func setCustomMenuButtonColorTo(_ color: UIColor, textColor: UIColor) {
        CustomMenuButton<LabelCell>.appearance().backgroundColor = color
        CustomMenuButton<LabelCell>.appearance().setTitleColor(textColor, for: .normal)
        CustomMenuButton<LabelCell>.appearance().setTitleColor(textColor, for: .highlighted)
        CustomMenuButton<LabelCell>.appearance().layer.borderColor = textColor.cgColor

        CustomMenuButton<ImageCell>.appearance().backgroundColor = color
        CustomMenuButton<ImageCell>.appearance().setTitleColor(textColor, for: .normal)
        CustomMenuButton<ImageCell>.appearance().setTitleColor(textColor, for: .highlighted)
        CustomMenuButton<ImageCell>.appearance().layer.borderColor = textColor.cgColor
    }
   
    private static func setHeaderTextColorTo(_ color: UIColor) {
        HeaderLabel.appearance().textColor = color
    }
    
    private static func setBgColorTo(_ color: UIColor) {
        BaseView.appearance().backgroundColor = color
        UITableView.appearance(whenContainedInInstancesOf: [BaseView.self]).backgroundColor = color
        UITableViewCell.appearance(whenContainedInInstancesOf: [BaseView.self]).backgroundColor = color
    }
    
    private static func setLogoImage(_ image: UIImage?) {
        LogoImageView.appearance().image = image ?? UIImage.loadImage(named: "idv_logo")
    }
    
    private static func loadLogoImageFrom(_ imageUrl: String, callback: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            callback(nil)
            return
        }
        loadImage(from: url) { image in
            setLogoImage(image)
            callback(image)
        }
    }
    
    private static func loadImage(from url: URL, callback: @escaping (UIImage?) -> Void) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                callback(nil)
                return
            }
            callback(UIImage(data: data))
        }
    }
    
    private static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
     
    private static func setIconTintColorTo(_ color: UIColor) {
        TintColorHolderView.appearance().backgroundColor = color
    }
    
    private static func setProcessingColorTo(_ color: UIColor) {
        ProcessingColorHolderView.appearance().backgroundColor = color
    }
    
    private static func updateTextFieldAppearance() {
        UITextField.appearance(whenContainedInInstancesOf: [BaseView.self]).font = UIFont(name: "HelveticaNeue-Light", size: 15)
    }
    
    private static func setPingOneNavAppearanceTo(_ barTintColor: UIColor, textColor: UIColor, barButtonTintColor: UIColor) {
        let customNavBarAppearance = UINavigationBarAppearance()
        
        // Apply background.
        customNavBarAppearance.configureWithOpaqueBackground()
        customNavBarAppearance.backgroundColor = barTintColor
        
        // Apply text color.
        customNavBarAppearance.titleTextAttributes = [.foregroundColor: textColor]

        // Apply button color.
        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: barButtonTintColor]
        barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: barButtonTintColor]
        barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: barButtonTintColor]
        barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: barButtonTintColor]
        customNavBarAppearance.buttonAppearance = barButtonItemAppearance
        customNavBarAppearance.backButtonAppearance = barButtonItemAppearance
        customNavBarAppearance.doneButtonAppearance = barButtonItemAppearance
            
        UINavigationBar.appearance(whenContainedInInstancesOf: [PingOneNavController.self]).tintColor = barButtonTintColor
        UINavigationBar.appearance(whenContainedInInstancesOf: [PingOneNavController.self]).scrollEdgeAppearance = customNavBarAppearance
        UINavigationBar.appearance(whenContainedInInstancesOf: [PingOneNavController.self]).compactAppearance = customNavBarAppearance
        UINavigationBar.appearance(whenContainedInInstancesOf: [PingOneNavController.self]).standardAppearance = customNavBarAppearance
    }
    
    private static func setIconImageViewTintColorTo(iconTintColor: UIColor) {
        IconImageView.appearance().tintColor = iconTintColor
    }
}
