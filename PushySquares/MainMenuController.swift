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
        
        let startButton = PressableButton(frame:
            CGRect.zero
            .with(width: startButtonWidth)
            .with(x: startButtonX)
            .with(y: startButtonY)
            .with(height: view.height / 10))
        let fontSize = fontSizeThatFits(size: startButton.frame.size, text: "START", font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
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
