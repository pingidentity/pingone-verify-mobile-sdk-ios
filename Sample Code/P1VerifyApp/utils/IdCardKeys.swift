//
//  IdCardKeys.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/23/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import P1VerifyIDSchema

struct IdCardKeys {
    
    static let cardTypeSelfie = "selfie"
    static let cardTypeDriverLicense = "driver_license"
    static let cardTypePassport = "passport"
    static let cardType = "cardType"
    static let frontImage = "frontImage"
    static let backImage = "backImage"
    static let cardId = "cardId"
    static let fullName = "fullName"
    static let address = "address"
    static let firstName = "firstName"
    static let middleName = "middleName"
    static let lastName = "lastName"
    static let gender = "gender"
    static let addressStreet = "addressStreet"
    static let addressCity = "addressCity"
    static let addressState = "addressState"
    static let addressZip = "addressZip"
    static let country = "country"
    static let issueDate = "issueDate"
    static let expirationDate = "expirationDate"
    static let birthDate = "birthDate"
    static let idNumber = "idNumber"
    static let weight = "weight"
    static let height = "height"
    static let hairColor = "hairColor"
    static let eyeColor = "eyeColor"
    static let nationality = "nationality"
    static let personalNumber = "personalNumber"

    static let keysMapping: [String: String] = [
        fullName: "Name",
        address: "Address",
        firstName: "First Name",
        middleName: "Middle Name",
        lastName: "Last Name",
        gender: "Gender",
        addressStreet: "Street",
        addressCity: "City",
        addressState: "State",
        addressZip: "Zip",
        country: "Country",
        issueDate: "Issue Date",
        expirationDate: "Expiration Date",
        birthDate: "Birth Date",
        idNumber: "ID Number",
        weight: "Weight",
        height: "Height",
        hairColor: "Hair Color",
        eyeColor: "Eye Color",
        nationality: "Nationality",
        personalNumber: "Personal Number",
        cardTypeSelfie: "Selfie",
        cardTypeDriverLicense: "Driver License",
        cardTypePassport: "Passport"
    ]
    
    static func getDisplayKeyFor(_ key: String) -> String {
        return keysMapping[key]?.localized ?? key.localized
    }

}
