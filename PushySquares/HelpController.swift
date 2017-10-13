import UIKit
import SwiftyButton

class HelpController: UIViewController, UIWebViewDelegate {
    func repositionViews() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
    }
}
