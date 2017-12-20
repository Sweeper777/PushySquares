import UIKit
import FSPagerView
import SwiftyButton

class MapSelectorViewController: UIViewController {
    var selectedMap: String? {
        didSet {
            delegate?.didSelectMap(mapSelectorController: self)
        }
    }
    weak var delegate: MapSelectorViewControllerDelegate?
    
    var pageView: FSPagerView!
    var pageControl: FSPageControl!
}
