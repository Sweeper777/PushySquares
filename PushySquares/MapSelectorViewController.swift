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
    
    var maps = allMaps.map {
        name -> Map in
        let path = Bundle.main.path(forResource: name, ofType: "map")!
        return Map(file: path)
    }
    
    func repositionViews() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
        let backButtonWeight: CGFloat
        if self.traitCollection.verticalSizeClass == .compact {
            backButtonWeight = 1.0 / 7.0
        } else {
            backButtonWeight = 1.0 / 12.0
        }
        let backButtonY = UIScreen.statusBarHeight + 8
        let backButtonX = 8.f
        let backButtonHeight = (view.height - 8) * backButtonWeight
        let backButtonWidth = 2 * backButtonHeight
        let backButton = PressableButton(frame: CGRect(x: backButtonX, y: backButtonY, width: backButtonWidth, height: backButtonHeight))
        let fontSize = fontSizeThatFits(size: backButton.frame.size, text: "BACK", font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        backButton.setAttributedTitle(
            NSAttributedString(string: "BACK", attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        backButton.colors = PressableButton.ColorSet(button: UIColor.gray, shadow: UIColor.gray.darker())
        backButton.shadowHeight = backButton.height * 0.1
        self.view.addSubview(backButton)
        
        let separator = backButton.height / 2
        let pageViewX = backButtonX
        let pageViewY = backButton.frame.maxY + separator
        let pageViewHeight = (view.height - pageViewY - 8) * (10.0 / 11.0) - 8
        let pageViewWidth = view.width - pageViewX - 8
        pageView = FSPagerView(frame: CGRect(x: pageViewX, y: pageViewY, width: pageViewWidth, height: pageViewHeight * 0.9))
        self.view.addSubview(pageView)
        pageView.transformer = FSPagerViewTransformer(type: .linear)
        pageView.register(UINib(nibName: "GameBoardCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        pageView.delegate = self
        pageView.dataSource = self
        let itemLength = min(pageViewWidth * 0.7, pageViewHeight)
        pageView.itemSize = CGSize(width: itemLength, height: itemLength)
        pageView.isInfinite = true
        
        let pageControlHeight = min(pageViewHeight, pageViewWidth) / 10
        let pageControlY = pageView.frame.maxY
        pageControl = FSPageControl(frame: CGRect(x: pageViewX, y: pageControlY, width: pageViewWidth, height: pageControlHeight))
        pageControl.numberOfPages = allMaps.count
        pageControl.currentPage = pageView.currentIndex
        pageControl.setStrokeColor(.black, for: .normal)
        pageControl.setStrokeColor(.black, for: .selected)
        pageControl.setFillColor(.clear, for: .normal)
        pageControl.setFillColor(.black, for: .selected)
        self.view.addSubview(pageControl)
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    func back() {
        selectedMap = allMaps[pageView.currentIndex]
        dismiss(animated: true, completion: nil)
    }
}