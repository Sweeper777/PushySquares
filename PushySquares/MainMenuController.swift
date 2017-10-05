import UIKit
import SwiftyButton

class MainMenuController: UIViewController {
    @IBOutlet var logo: UIImageView!
    
    var viewsToBeRepositioned: [UIView] = []
    
    func repositionViews() {
        viewsToBeRepositioned.forEach { $0.removeFromSuperview() }
        viewsToBeRepositioned = []
    override func viewDidLoad() {
        repositionViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.repositionViews()
        }
    }
    }
}
