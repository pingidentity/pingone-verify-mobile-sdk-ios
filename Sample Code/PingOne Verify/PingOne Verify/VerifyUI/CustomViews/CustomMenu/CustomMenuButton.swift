//
//  CustomMenuButton.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/31/22.
//

import Foundation
import UIKit

class CustomMenuButton<T: CustomMenuItemCell>: UIButton {
    
    private var menuWindow: UIWindow?
    private var title: String?
    private var actions: [UIAction] = []
    private var visibleItems: Int = 0
    private var currentSelection: Int = 0
    
    private var menuTable: CustomMenu<T>!
    private var cellContent: [CustomMenuItemContent]!
    private var showArrowImage: Bool = false
    private var iconTintColor: UIColor!
    private let ARROW_ICON_GRADIENT = 1.0
    
    private var tapGestureRecognizer: UITapGestureRecognizer!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(showArrowImage: Bool, iconTintColor: UIColor?) {
        super.init(frame: CGRect())
        self.showArrowImage = showArrowImage
        self.iconTintColor = iconTintColor ?? UIColor.gray
    }
    
    public func setItems(title: String? = nil, _ actions: [UIAction], cellContent: [CustomMenuItemContent], cellClass: T.Type) {
        self.actions = actions
        self.title = title
        
        self.configureMenuWindow()
    
        self.menuTable = CustomMenu<T>()
        self.cellContent = cellContent

        self.addTarget(self, action: #selector(self.showMenu(_:)), for: .touchUpInside)
        
        if showArrowImage {
            if var arrowDownImage = UIImage.loadImage(named: "arrow_drop_down") {
                arrowDownImage = arrowDownImage.addGradient(color: self.iconTintColor, gradientFactor: self.ARROW_ICON_GRADIENT)
                self.setImage(arrowDownImage, for: .normal)
            }
            
            if var arrowUpImage = UIImage.loadImage(named: "arrow_drop_up") {
                arrowUpImage = arrowUpImage.addGradient(color: self.iconTintColor, gradientFactor: self.ARROW_ICON_GRADIENT)
                self.setImage(arrowUpImage, for: .highlighted)
            }
        }
    }
    
    public func setMaxVisibleItems(_ maxVisibleItems: Int) {
        self.visibleItems = maxVisibleItems
    }

    public func setCurrentSelectedItem(index: Int) {
        self.currentSelection = index
    }
    
    @objc private func showMenu(_ sender: UIButton) {
        if showArrowImage {
            if var arrowUpImage = UIImage.loadImage(named: "arrow_drop_up") {
                arrowUpImage = arrowUpImage.addGradient(color: self.iconTintColor, gradientFactor: self.ARROW_ICON_GRADIENT)
                self.setImage(arrowUpImage, for: .normal)
            }
        }

        let menuFrame = self.calculateMenuFrame()
        self.menuTable.frame = menuFrame
        self.menuTable.backgroundColor = UIColor.white

        self.menuWindow?.addSubview(self.menuTable)

        self.menuTable.setMenuItems(title: self.title, self.cellContent) { index in
            guard index >= 0 else {
                return
            }

            let action = self.actions[index]
            action.handler?(action)
        }
        
        self.menuWindow?.makeKeyAndVisible()
    }
    
    private func calculateMenuFrame() -> CGRect {
        let screenSize = UIScreen.main.bounds
        let safeAreaTopPadding = self.window?.safeAreaInsets.top ?? 0
        let safeAreaBottomPadding = self.window?.safeAreaInsets.bottom ?? 0
        let buttonFrame = self.frame
        let newButtonFrame =  CGRect(origin: self.superview?.convert(buttonFrame.origin, to: nil) ?? buttonFrame.origin, size: buttonFrame.size)
        
        let topSpace = newButtonFrame.origin.y - safeAreaTopPadding
        let bottomSpace = screenSize.height - (newButtonFrame.origin.y + frame.height) - safeAreaBottomPadding
        
        let maxItemWidth = max(UILabel.textWidth(font: UIFont.systemFont(ofSize: CustomMenuConstants.ITEM_LABEL_FONT, weight: .regular), text: self.actions.max { action1, action2 in
            let size1 = UILabel.textWidth(font: UIFont.systemFont(ofSize: CustomMenuConstants.ITEM_LABEL_FONT, weight: .regular), text: action1.title)
            let size2 = UILabel.textWidth(font: UIFont.systemFont(ofSize: CustomMenuConstants.ITEM_LABEL_FONT, weight: .regular), text: action2.title)
            return size2 > size1
        }?.title ?? "") + CustomMenuConstants.ITEM_X_PADDING, UILabel.textWidth(font: UIFont.systemFont(ofSize: CustomMenuConstants.SECTION_HEADER_FONT, weight: .bold), text: self.title ?? "") + CustomMenuConstants.ITEM_X_PADDING)
        let totalItems = (self.visibleItems > 0 ? self.visibleItems : self.actions.count) + (self.title == nil ? 0 : 1)
        let menuWidth: CGFloat = min(screenSize.width - CustomMenuConstants.MENU_SIZE_PADDING, max(self.bounds.width, maxItemWidth))
        let maxMenuHeight: CGFloat = (CGFloat(totalItems) * CustomMenuConstants.MENU_CELL_HEIGHT) + CustomMenuConstants.MENU_SIZE_PADDING
        let menuXPoint: CGFloat = newButtonFrame.origin.x - (abs(self.bounds.width - menuWidth)/2)

        let menuYPoint: CGFloat
        let menuHeight: CGFloat
        if (bottomSpace.isLess(than: topSpace)) {
            menuHeight = min(topSpace - CustomMenuConstants.MENU_SIZE_PADDING, maxMenuHeight)
            menuYPoint = newButtonFrame.origin.y - menuHeight - CustomMenuConstants.MENU_Y_PADDING
        } else {
            menuHeight = min(bottomSpace - CustomMenuConstants.MENU_SIZE_PADDING, maxMenuHeight)
            menuYPoint = newButtonFrame.origin.y + self.bounds.height + CustomMenuConstants.MENU_Y_PADDING
        }
        
        return CGRect(x: menuXPoint, y: menuYPoint, width: CGFloat(menuWidth), height: menuHeight)
    }
    
    private func configureMenuWindow() {
        self.menuWindow = UIWindow(frame: self.window?.frame ?? UIScreen.main.bounds)
        self.menuWindow?.windowLevel = .alert
        self.menuWindow?.isUserInteractionEnabled = true
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onMenuSuperViewTap(_:)))
        self.tapGestureRecognizer.cancelsTouchesInView = false
        self.menuWindow?.addGestureRecognizer(self.tapGestureRecognizer)
    }
    
    @objc func onMenuSuperViewTap(_ sender: UITapGestureRecognizer) {
        self.menuWindow?.isHidden = true
        if showArrowImage {
            if var arrowDownImage = UIImage.loadImage(named: "arrow_drop_down") {
                arrowDownImage = arrowDownImage.addGradient(color: self.iconTintColor, gradientFactor: self.ARROW_ICON_GRADIENT)
                self.setImage(arrowDownImage, for: .normal)
            }
        }
    }
    
}
