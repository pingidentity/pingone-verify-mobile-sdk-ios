//
//  DocumentSelectionViewController.swift
//  PingOneVerify
//
//  Created by Keerthi Devipriya on 16/06/25.
//

import UIKit

protocol DocumentCallBack: AnyObject {
    func didSelectDocument(_ document: DocumentModel)
}

class DocumentSelectionViewController: BaseViewController {
    
    var documentsList: [DocumentModel] = []
    @IBOutlet weak var titleLbl: HeaderLabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var documentsTableView: UITableView!
    var callback: ((DocumentModel) -> Void)?
    var delegate: DocumentCallBack?
    var idDocument: [String: String]?
    
    internal class func getViewController(
        delegate: DocumentCallBack
    ) -> DocumentSelectionViewController {
        let bundle: Bundle = Bundle(for: DocumentSelectionViewController.self)
        let documentSelectionViewController = DocumentSelectionViewController(nibName: "DocumentSelectionVC", bundle: bundle)
        documentSelectionViewController.delegate = delegate
        return documentSelectionViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setHeaderView()
        self.documentsList = self.getDocumentsList()
        documentsTableView.delegate = self
        documentsTableView.dataSource = self
        self.documentsTableView.register(
            UINib(
                nibName: "DocumentSelectionCell",
                bundle: Bundle(for: DocumentSelectionCell.self)
            ),
            forCellReuseIdentifier: "DocumentSelectionCell"
        )
    }
    
    func setHeaderView() {
        if let headerText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_documentCapture_header_type") {
            self.titleLbl.attributedText = headerText
        } else {
            self.titleLbl.text = "idv_documentCapture_header_type".localized
        }
        
        if let descText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_documentCapture_description_type") {
            self.descLbl.attributedText = descText
        } else {
            self.descLbl.text = "idv_documentCapture_description_type".localized
        }
    }
    
    func getDocumentsList() -> [DocumentModel] {
        return [
            DocumentModel(documentType: .DRIVER_LICENSE, textValue: "idv_documentCapture_option_license".localized),
            DocumentModel(documentType: .PASSPORT, textValue: "idv_documentCapture_option_passport".localized),
            DocumentModel(documentType: .PASSPORT, textValue: "idv_documentCapture_option_card".localized),
            DocumentModel(documentType: .OTHER, textValue: "idv_documentCapture_option_other".localized)
        ]
    }
}

extension DocumentSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentSelectionCell") as! DocumentSelectionCell
        cell.documentType.setTitle(documentsList[indexPath.row].getTextValue(), for: .normal)
        cell.documentType.borderColor = .clear
        cell.documentType.fontColor = UIColor.black
        cell.documentType.contentHorizontalAlignment = .left
        cell.documentType.titleFont =  UIFont(name:"HelveticaNeue-Bold", size: 32) ?? UIFont.boldSystemFont(ofSize: 20)
        cell.documentType.layer.shadowColor = UIColor(hexString: "#C8DEFF").cgColor
        cell.documentType.layer.shadowOpacity = 0.5
        cell.documentType.layer.shadowRadius = 0
        cell.documentType.layer.shadowOffset = CGSizeMake(0, 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectDocument(documentsList[indexPath.row])
    }
}

extension DocumentSelectionViewController {
    func didSelectDocument(_ documentModel: DocumentModel) {
        self.delegate?.didSelectDocument(documentModel)
    }
}
