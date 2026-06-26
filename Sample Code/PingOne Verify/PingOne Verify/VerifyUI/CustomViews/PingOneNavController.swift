import Foundation
import UIKit

internal class PingOneNavController: UINavigationController {

    var verifyHelper: PingOneVerifyHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
    }

    deinit {
        print("🗑️ PingOneNavController deallocated")
        self.verifyHelper = nil
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        DocumentSubmissionTimer.shared.reset()
        super.dismiss(animated: flag, completion: completion)
    }
}
