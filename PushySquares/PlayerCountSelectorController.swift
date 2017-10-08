import UIKit
import SwiftyButton

class PlayerCountSelectorController: UIViewController {
    
    func repositionViews() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
    }
}
