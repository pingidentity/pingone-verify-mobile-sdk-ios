//
//  ProcessingViewController.swift
//  PingOneVerify
//
//  Created by Abhishek Mahuri on 05/08/24.
//

import UIKit

class ProcessingViewController: BaseViewController {
    
    @IBOutlet weak var firstDot: UIView!
    @IBOutlet weak var secondDot: UIView!
    @IBOutlet weak var thirdDot: UIView!
    
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var processingStackView: UIStackView!
    
    var views: [UIView] = []
    var processingTimer: Timer?
    var colors: [UIColor]?
    var zeroIndex = 0
    var firstIndex = 1
    var secondIndex = 2
    var processingColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
        self.processingColor = ProcessingColorHolderView.appearance().backgroundColor
        startColorChangeTimer()
        if let processingAttributedText = AttributedStringProvider.shared.fetchAttributedStringFor("idv_data_processing") {
            processingLabel.attributedText = processingAttributedText
        } else {
            processingLabel.text = "idv_data_processing".localized
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.setNavigationBarHidden(true, animated: animated)
   }
   
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       self.navigationController?.setNavigationBarHidden(false, animated: animated)
   }
    
    internal class func getViewController() -> ProcessingViewController {
        let bundle: Bundle = Bundle(for: ProcessingViewController.self)
        let processingViewController = ProcessingViewController(nibName: "ProcessingViewController", bundle: bundle)
        return processingViewController
    }
    
    func setupStackView() {
        self.firstDot.layer.cornerRadius = DataCaptureConstants.PROCESSING_CORNER_RADIUS
        self.secondDot.layer.cornerRadius = DataCaptureConstants.PROCESSING_CORNER_RADIUS
        self.thirdDot.layer.cornerRadius = DataCaptureConstants.PROCESSING_CORNER_RADIUS
        processingStackView.translatesAutoresizingMaskIntoConstraints = false
        
        views.append(firstDot)
        views.append(secondDot)
        views.append(thirdDot)
    }
    
    func startColorChangeTimer() {
        processingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(showAnimation), userInfo: nil, repeats: true)
    }
    
    @objc func showAnimation() {
        let midProcessingColor = (processingColor?.withAlphaComponent(0.5))!
        let lightProcessingColor = (processingColor?.withAlphaComponent(0.2))!
        let colors = [lightProcessingColor, midProcessingColor, processingColor]
        
        views[0].backgroundColor = colors[zeroIndex]
        views[1].backgroundColor = colors[firstIndex]
        views[2].backgroundColor = colors[secondIndex]
                
        zeroIndex = incrementNumber(num: zeroIndex)
        firstIndex = incrementNumber(num: firstIndex)
        secondIndex = incrementNumber(num: secondIndex)
    }
    
    func incrementNumber(num: Int) -> Int {
        return (num + 2) % 3
    }
    
    deinit {
        processingTimer?.invalidate()
    }
}
