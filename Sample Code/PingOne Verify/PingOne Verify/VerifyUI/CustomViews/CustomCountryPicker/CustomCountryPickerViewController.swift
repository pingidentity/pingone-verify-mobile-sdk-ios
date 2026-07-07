//
//  CustomCountryPickerViewController.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 7/20/23.
//

import UIKit

class CustomCountryPickerViewController: UIViewController {
    var filteredResults: [String]!
    var searchResults: [String]!
    var countries: [String]!
    var countryCodePickerListener: CustomCountryCodePickerListener!
    
    let CUSTOM_COUNTRY_PICKER_CELL_IDENTIFIER = "CustomCountryPickerCellIdentifier"
    let CUSTOM_COUNTRY_PICKER_CELL_NIB = "CustomCountryPickerCell"
    
    var searchController: UISearchController!

    @IBOutlet weak var countryPickerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateNavigationBar()
        self.configureSearchBar()
        
        self.countryPickerTableView.register(UINib(nibName: self.CUSTOM_COUNTRY_PICKER_CELL_NIB, bundle: Bundle(for: Self.self)), forCellReuseIdentifier: self.CUSTOM_COUNTRY_PICKER_CELL_IDENTIFIER)

        self.loadCountries()
        countryPickerTableView.estimatedRowHeight = 50 
        countryPickerTableView.rowHeight = UITableView.automaticDimension
    }
    
    internal class func getViewController(countryCodePickerListener: CustomCountryCodePickerListener) -> CustomCountryPickerViewController {
        let bundle: Bundle = Bundle(for: CustomCountryPickerViewController.self)
        let customCountryPickerViewController = CustomCountryPickerViewController(nibName: "CustomCountryPickerViewController", bundle: bundle)
        customCountryPickerViewController.countryCodePickerListener = countryCodePickerListener
        
        return customCountryPickerViewController
    }

    private func loadCountries() {
        guard let countries = CountryCodes.loadJson() else {
            return
        }
        
        self.countries = countries.map({ $0.name + ": " + $0.dialCode})
        self.filteredResults = self.countries
        self.searchResults = self.countries

        self.countryPickerTableView.delegate = self
        self.countryPickerTableView.dataSource = self
        
        self.countryPickerTableView.layer.cornerRadius = DataCaptureConstants.TEXT_FIELD_CORNER_RADIUS
        self.countryPickerTableView.backgroundColor = .clear
        self.countryPickerTableView.showsVerticalScrollIndicator = true
        self.countryPickerTableView.isScrollEnabled = true
        self.countryPickerTableView.layer.zPosition = 1.0
        self.countryPickerTableView.tableHeaderView?.backgroundColor = .clear
    }
    
    private func configureSearchBar() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.isTranslucent = true
        self.searchController.searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.searchController.searchBar.backgroundColor = .clear
        self.searchController.searchBar.placeholder = "idv_countryCode_search_bar_placeholder".localized
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.obscuresBackgroundDuringPresentation = false
        
        self.definesPresentationContext = true
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController?.searchBar.searchTextField.backgroundColor = .white
        if let iconTintColor = TintColorHolderView.appearance().backgroundColor {
            self.navigationItem.searchController?.searchBar.searchTextField.layer.borderColor = iconTintColor.cgColor
            self.navigationItem.searchController?.searchBar.searchTextField.leftView?.tintColor = iconTintColor
        }
        self.navigationItem.searchController?.searchBar.searchTextField.textColor = AppthemeHandler.bodyTextColor
    }
    
    private func updateNavigationBar() {
        DispatchQueue.main.async {
            if let cancelImage = UIImage.loadImage(named: "idv_cancel") {
                let cancelButton = UIBarButtonItem(image: cancelImage, style: .plain, target: self, action: #selector(self.cancelClicked(sender:)))
                self.navigationItem.leftBarButtonItem = cancelButton
            } else {
                logerror("Missing cancel image")
            }
        }
    }
    
    @objc func cancelClicked(sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
