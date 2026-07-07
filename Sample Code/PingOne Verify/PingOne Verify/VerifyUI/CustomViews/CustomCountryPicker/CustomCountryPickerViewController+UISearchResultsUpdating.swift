//
//  CustomCountryPickerViewController+UISearchResultsUpdating.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 7/20/23.
//

import Foundation
import UIKit

extension CustomCountryPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredResults = self.filterResults(searchController.searchBar.text ?? "")
    }
    
    func filterResults(_ input: String) -> [String] {
        if (input.isEmpty) {
            self.filteredResults = searchResults
        } else {
            let predicate = NSPredicate(format: "SELF contains[c] %@",input) // For elements that contain input string
            let allResults = NSArray(array: self.searchResults)
            self.filteredResults = allResults.filtered(using: predicate) as? [String] ?? self.filteredResults
        }
        
        DispatchQueue.main.async {
            self.countryPickerTableView.reloadData()
        }
        
        return self.filteredResults
    }
}
