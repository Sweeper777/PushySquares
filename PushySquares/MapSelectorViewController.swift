import UIKit
import FSPagerView
import SwiftyButton
import SCLAlertView
import StoreKit
import EZLoadingActivity

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
    
    var productRequest: SKProductsRequest!
    
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
        if pageView.currentIndex > 3 && !UserDefaults.standard.bool(forKey: "mapsUnlocked") {
            promptUnlockMaps()
        } else {
            selectedMap = allMaps[pageView.currentIndex]
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            [weak self] in
            self?.repositionViews()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionViews()
    }
    
    override func viewDidLayoutSubviews() {
        let index = selectedMap == nil ? 0 : allMaps.indexes(of: selectedMap!).first!
        guard pageView != nil && pageView.numberOfItems > 0 else { return }
        pageView?.scrollToItem(at: index, animated: false)
    }
}

extension MapSelectorViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return maps.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let gameBoardCell = cell as! GameBoardCell
        gameBoardCell.game = Game(map: maps[index], playerCount: 4)
        gameBoardCell.locked = index > 3 && !UserDefaults.standard.bool(forKey: "mapsUnlocked")
        cell.imageView?.contentMode = .scaleAspectFit
        cell.contentView.layer.shadowRadius = 0
        return cell
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        if index > 3 && !UserDefaults.standard.bool(forKey: "mapsUnlocked") {
            promptUnlockMaps()
        }
    }
    
    fileprivate func promptUnlockMaps() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Unlock All Maps") { [weak self] in
        alert.addButton("Cancel", action: {})
        alert.showInfo("This map is locked!", subTitle: "Do you want to unlock all locked maps?", circleIconImage: #imageLiteral(resourceName: "lockedIcon"))
    }
}

extension MapSelectorViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        EZLoadingActivity.hide()
        if let product = response.products.first {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            let price = numberFormatter.string(from: product.price)
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("Unlock All Maps for \(price!)") { [weak self] in
                guard let `self` = self else { return }
                if SKPaymentQueue.canMakePayments() {
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(SKPayment(product: product))
                    EZLoadingActivity.show("Loading...", disableUI: true)
                } else {
                    self.showIAPError(message: "Purchases are disabled on this device!")
                }
            }
            alert.addButton("Restore Purchase") { [weak self] in
                guard let `self` = self else { return }
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
                EZLoadingActivity.show("Loading...", disableUI: true)
            }
        } else {
            showIAPError(message: "Unable to get product information. Please check your Internet connection.")
        }
    }
    func showIAPError(message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("OK", action: {})
        alert.showError("Oops!", subTitle: message)
    }
}
    }
}
