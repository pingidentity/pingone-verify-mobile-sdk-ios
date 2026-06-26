//
//  AppthemeHandler.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 14/11/24.
//

import UIKit

class AppthemeHandler {

    static var bodyTextColor: UIColor { BaseViewController.appTheme?.configuration.bodyTextColor ?? UIColor(hexString: ThemeConfig.DEFAULT_BODY_TEXT_COLOR) }
    static var buttonColor: UIColor { BaseViewController.appTheme?.configuration.solidButtonAppearance.getBackgroundColor() ?? UIColor(hexString: ThemeConfig.DEFAULT_BUTTON_COLOR) }
    static var buttonTextColor: UIColor { BaseViewController.appTheme?.configuration.solidButtonAppearance.getTextColor() ?? UIColor(hexString: ThemeConfig.DEFAULT_BUTTON_TEXT_COLOR) }
    static var borderedButtonColor: UIColor { BaseViewController.appTheme?.configuration.borderedButtonAppearance.getBackgroundColor() ?? UIColor(hexString: ThemeConfig.DEFAULT_BUTTON_TEXT_COLOR) }
    static var borderedButtonTextColor: UIColor { BaseViewController.appTheme?.configuration.borderedButtonAppearance.getTextColor() ?? UIColor(hexString: ThemeConfig.DEFAULT_BUTTON_COLOR) }
    static var borderedButtonBorderColor: UIColor { BaseViewController.appTheme?.configuration.borderedButtonAppearance.getBorderColor() ?? UIColor(hexString: ThemeConfig.DEFAULT_BUTTON_COLOR) }
    static var headingTextColor: UIColor { BaseViewController.appTheme?.configuration.headingTextColor ?? UIColor(hexString: ThemeConfig.DEFAULT_HEADING_TEXT_COLOR) }
    static var selfieOvalSuccessColor: UIColor { BaseViewController.appTheme?.configuration.selfieOvalSuccessColor ?? UIColor.loadColor(named: "idv_selfie_guideline_success") ?? .green }
    static var selfieOvalDefaultColor: UIColor { BaseViewController.appTheme?.configuration.selfieOvalDefaultColor ?? UIColor.loadColor(named: "idv_selfie_guideline_default") ?? .white }
    static var selfieOvalErrorColor: UIColor { BaseViewController.appTheme?.configuration.selfieOvalErrorColor ?? UIColor.loadColor(named: "idv_selfie_guideline_error") ?? .red }

}
