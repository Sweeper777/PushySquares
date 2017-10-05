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
    }
}
