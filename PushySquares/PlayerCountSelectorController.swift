import UIKit
import SwiftyButton

class PlayerCountSelectorController: UIViewController {
    
    func repositionViews() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            [weak self] in
            self?.repositionViews()
        }
    }
    }
}
