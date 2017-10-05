import UIKit
import SwiftyButton

class MainMenuController: UIViewController {
    @IBOutlet var logo: UIImageView!
    
    var viewsToBeRepositioned: [UIView] = []
    
    func repositionViews() {
        viewsToBeRepositioned.forEach { $0.removeFromSuperview() }
        viewsToBeRepositioned = []
        
        let startButtonY = 36 + view.height / 2
        let startButtonWidth: CGFloat
        if traitCollection.horizontalSizeClass == .regular {
            startButtonWidth = view.width / 2
        } else {
            startButtonWidth = view.width * 0.8
        }
        let startButtonX = (view.width - startButtonWidth) / 2
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
