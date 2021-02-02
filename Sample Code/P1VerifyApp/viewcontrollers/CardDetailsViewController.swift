//
//  CardDetailsViewController.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/13/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit
import ShoLib
import P1VerifyIDSchema

class CardDetailsViewController: UIViewController {
    
    let CELL_REUSE_IDENTIFIER: String = "CardParamTableViewCell"
    
    var cardParams: [String: Any]!
    var frontImage: UIImage?
    var backImage: UIImage?
    var cardDictionary: [String: String]!
    
    var isShowingFrontImage: Bool = true {
        didSet {
            self.cardImagePageControl.currentPage = self.isShowingFrontImage ? 0 : 1
        }
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var secondaryHeaderLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardImagePageControl: UIPageControl!
    @IBOutlet weak var editCardButton: UIButton!
    @IBOutlet weak var deleteCardButton: UIButton!
    @IBOutlet weak var paramsTable: UITableView!
    
    var keys: [[String]] = [[IdCardKeys.fullName], [IdCardKeys.address], [IdCardKeys.idNumber, IdCardKeys.expirationDate, IdCardKeys.birthDate, IdCardKeys.country, IdCardKeys.gender, IdCardKeys.hairColor, IdCardKeys.eyeColor, IdCardKeys.height, IdCardKeys.weight]]
    
    class func getViewControllerFor(cardParams: [String: Any], frontImage: UIImage?, backImage: UIImage?) -> CardDetailsViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardDetailsViewController") as! CardDetailsViewController
        vc.cardParams = cardParams
        vc.frontImage = frontImage
        vc.backImage = backImage
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupImageView()
        
        self.prepareCardDictionary()
        self.headerLabel.text = IdCardKeys.getDisplayKeyFor(self.cardDictionary[IdCardKeys.cardType] ?? "Card".localized)
        if let stateCode = self.cardDictionary[IdCardKeys.addressState] {
            self.secondaryHeaderLabel.text = USStates.getStateForStateCode(stateCode)
        } else {
            self.secondaryHeaderLabel.text = self.cardDictionary[IdCardKeys.country]
        }
        self.editCardButton.isHidden = true
        
        guard let cardType = self.cardParams[IdCardKeys.cardType] as? String,
              cardType == IdCardKeys.cardTypeDriverLicense else {
            return
        }
 
        self.paramsTable.dataSource = self
        self.paramsTable.delegate = self
        self.paramsTable.register(CardParamTableViewCell.nib, forCellReuseIdentifier: CELL_REUSE_IDENTIFIER)
    }
    
    func prepareCardDictionary() {
        self.cardDictionary  = self.cardParams.reduce(into: [String: String](), { if let val = $1.value as? String { $0[$1.key] = val } })
        
        var fullName = ""
        if let firstName = self.cardDictionary[IdCardKeys.firstName] {
            fullName += firstName + " "
        }
        if let middleName = self.cardDictionary[IdCardKeys.middleName] {
            fullName += middleName + " "
        }
        if let lastName = self.cardDictionary[IdCardKeys.lastName] {
            fullName += lastName + " "
        }
        self.cardDictionary[IdCardKeys.fullName] = fullName
        
        var addressString = ""
        if let streetAddress = self.cardDictionary[IdCardKeys.addressStreet], !streetAddress.isEmpty {
            addressString.append("\(streetAddress)\n")
        }
        if let city = self.cardDictionary[IdCardKeys.addressCity], !city.isEmpty {
            addressString.append("\(city), ")
        }
        let state = self.cardDictionary[IdCardKeys.addressState]
        let zip = self.cardDictionary[IdCardKeys.addressZip]
        addressString.append("\(state ?? "") \(zip ?? "")")
        self.cardDictionary[IdCardKeys.address] = addressString
    }
        
    private func setupImageView() {
        self.cardImageView.image = self.frontImage
        guard let _ = self.backImage else {
            self.cardImagePageControl.numberOfPages = 1
            return
        }
        
        self.cardImagePageControl.numberOfPages = 2
        self.cardImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCardImageTapped(_:)))
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.onCardImageSwiped(_:)))
        leftSwipeGesture.direction = .left
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.onCardImageSwiped(_:)))
        rightSwipeGesture.direction = .right
        
        self.cardImageView.addGestureRecognizer(tapGesture)
        self.cardImageView.addGestureRecognizer(leftSwipeGesture)
        self.cardImageView.addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc func onCardImageSwiped(_ sender: UISwipeGestureRecognizer) {
        self.changeImage(sender.direction == .left)
    }
    
    @objc func onCardImageTapped(_ sender: UITapGestureRecognizer) {
        self.changeImage(self.isShowingFrontImage)
    }
    
    private func changeImage(_ isLeftSwipe: Bool) {
        let nextImage = self.isShowingFrontImage ? self.backImage : self.frontImage
        if let nextImage = nextImage {
            let animationDirection: AnimationDirection = !isLeftSwipe ? .fromLeft: .fromRight
            self.cardImageView.changeImageWithFlipAnimation(direction: animationDirection, image: nextImage, duration: 1.0)
            self.isShowingFrontImage = !self.isShowingFrontImage
        }
    }
    
    @IBAction func onPageControlValueChanged(_ sender: UIPageControl) {
        self.changeImage(true)
    }
    
    @IBAction func onEditButtonClicked(_ sender: UIButton) {
        //Do Nothing
    }
    
    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "delete_card".localized, message: "confirm_delete_card".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm".localized, style: .default, handler: {_ in
            StorageManager.shared.deleteCardWithId(self.cardParams["cardId"] as! String)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.show()
    }
}

extension CardDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keys[section].count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.1 : 30.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard section > 0, let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        headerView.backgroundView = bgView
        
        let dividerView = UIView(frame: CGRect(x: 0.0, y: headerView.frame.height / 2.0, width: headerView.frame.width, height: 1.0))
        dividerView.backgroundColor = UIColor(netHex: 0x494946)
        
        headerView.addSubview(dividerView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let paramCell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_IDENTIFIER, for: indexPath) as? CardParamTableViewCell else {
            return UITableViewCell()
        }
        
        let key = self.keys[indexPath.section][indexPath.row]

        paramCell.paramKey.text = IdCardKeys.getDisplayKeyFor(key)
        paramCell.paramValue.text = self.getFormattedValueFor(key: key)
        
        return paramCell
    }
    
    
    private func getFormattedValueFor(key: String) -> String {
        guard let value = self.cardDictionary[key], !value.isEmpty else {
            return "Not Available".localized
        }
        
        return value
    }
    
}
