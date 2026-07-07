//
//  CustomCountryPickerViewController+UITableViewDelegate.swift
//  PingOneVerify_iOS
//
//  Created by Caleb Cho on 7/20/23.
//

import Foundation
import UIKit

extension CustomCountryPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: self.CUSTOM_COUNTRY_PICKER_CELL_IDENTIFIER)
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let countryString = self.filteredResults[indexPath.row]
        
        guard let colonRange = countryString.range(of: ":"),
              let plusRange = countryString.range(of: "+") else {
            return cell
        }
        
        let countryName = String(countryString[..<colonRange.lowerBound])
        let countryCode = "+" + String(countryString[plusRange.upperBound...])
        
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = UIFont(name: "HelveticaNeue-Light", size: 15) ?? .systemFont(ofSize: 15)
        content.text = countryName

        content.secondaryTextProperties.font = UIFont(name: "HelveticaNeue-Light", size: 15) ?? .systemFont(ofSize: 15)
        content.secondaryText = countryCode
        content.textProperties.numberOfLines = 0
        content.textProperties.color = AppthemeHandler.bodyTextColor
        content.secondaryTextProperties.color = AppthemeHandler.bodyTextColor
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedValue = self.filteredResults[indexPath.row]
        let substrings = selectedValue.split(separator: ":")
        
        guard substrings.count == 2 else { return }
        
        DispatchQueue.main.async {
            self.countryCodePickerListener.onCountryCodePicked(code: String(substrings[1]).trimmingCharacters(in: .whitespaces))
            self.navigationController?.popViewController(animated: true)
        }
    }
}
