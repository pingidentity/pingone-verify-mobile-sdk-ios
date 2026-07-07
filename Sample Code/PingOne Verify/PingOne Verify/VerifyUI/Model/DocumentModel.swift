//
//  DocumentModel.swift
//  PingOneVerify
//
//  Created by Keerthi Devipriya on 17/06/25.
//

import Foundation
import NeoInterfaces

/// A simple value holder pairing a ``DocumentClass`` with an associated text value.
///
/// Used internally when constructing document payloads for OTP, email, or phone verification
/// steps where the captured data is a plain string rather than an image.
public class DocumentModel {
    private var documentType: DocumentClass
    private var textValue: String

    /// Creates a document model for the given type and text value.
    ///
    /// - Parameters:
    ///   - documentType: The class of document this model represents (e.g., `.OTP`, `.EMAIL`).
    ///   - textValue: The text payload for this document step (e.g., an OTP string, email address, or phone number).
    public init(documentType: DocumentClass, textValue: String) {
        self.documentType = documentType
        self.textValue = textValue
    }

    /// Returns the document class for this model.
    public func getDocumentType() -> DocumentClass {
        return self.documentType
    }

    /// Returns the text payload associated with this document (e.g., an OTP code or email address).
    public func getTextValue() -> String {
        return self.textValue
    }
}
