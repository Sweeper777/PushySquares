import UIKit
import FSPagerView
import SwiftyButton

class MapSelectorViewController: UIViewController {
    weak var delegate: MapSelectorViewControllerDelegate?
    
    var pageView: FSPagerView!
    var pageControl: FSPageControl!
}
