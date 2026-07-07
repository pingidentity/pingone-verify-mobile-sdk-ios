//
//  CustomMenu.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 8/31/22.
//

import Foundation
import UIKit

class CustomMenu<T: CustomMenuItemCell>: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuTable: UITableView!
    private var onItemSelected: ((_ index: Int) -> Void)?
    
    private var title: String?
    private var menuItems: [CustomMenuItemContent] = [] {
        didSet {
            self.menuTable.reloadData()
        }
    }
    private var currentSelection: Int = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    private func setupView() {
        let bundle = Bundle(for: type(of: self))
        if let nib = bundle.loadNibNamed("CustomMenu", owner: self) {
            if let subview = nib[0] as? UIView {
                subview.frame = self.bounds
                subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.addSubview(subview)
                self.configureTableView()
            }
        }
    }
    
    private func configureTableView() {
        self.menuTable.dataSource = self
        self.menuTable.delegate = self
        
        self.menuTable.separatorStyle = .singleLine
        self.menuTable.separatorColor = UIColor.lightGray
        self.menuTable.backgroundColor = UIColor.white
        self.menuTable.separatorInset = UIEdgeInsets(top: 0, left: CustomMenuConstants.CELL_SEPARATOR_INSET, bottom: 0, right: CustomMenuConstants.CELL_SEPARATOR_INSET)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = true
        
        self.menuTable.register(T.nib, forCellReuseIdentifier: CustomMenuConstants.ACTIONS_CELL_REUSE_IDENTIFIER)
    }
       
    public func setMenuItems(title: String? = nil, _ menuItems: [CustomMenuItemContent], onItemSelected: @escaping (_ index: Int) -> Void) {
        self.menuItems = menuItems
        self.title = title
        self.onItemSelected = onItemSelected
    }
    
    public func setCurrentSelectedItem(index: Int) {
        self.currentSelection = index
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
            let index = IndexPath(item: index, section: 0)
            self.menuTable.selectRow(at: index, animated: true, scrollPosition: .top)
        }
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CustomMenuConstants.SECTION_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            var content = header.defaultContentConfiguration()
            content.textProperties.alignment = .center
            content.text = self.title
            content.textProperties.color = .darkGray
            content.textProperties.font = .boldSystemFont(ofSize: CustomMenuConstants.SECTION_HEADER_FONT)
            header.contentConfiguration = content
            header.contentView.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomMenuConstants.ACTIONS_CELL_REUSE_IDENTIFIER, for: indexPath) as? T else {
            let cell = UITableViewCell()
            return cell
        }
        
        cell.populateCell(content: self.menuItems[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.menuTable.deselectRow(at: indexPath, animated: true)
        self.onItemSelected?(indexPath.item)
    }
}

