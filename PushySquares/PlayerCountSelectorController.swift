import UIKit
import SwiftyButton
import GoogleMobileAds
import FSPagerView
import SCLAlertView
import StoreKit
import EZLoadingActivity

class PlayerCountSelectorController: UIViewController {
    
    var interstitial: GADInterstitial!
    var pageView: FSPagerView!
    var pageControl: FSPageControl!
    var mapPageView: FSPagerView!
    var mapPageControl: FSPageControl!
    var shouldShowAd = false
    var productRequest: SKProductsRequest!
    
    let imageNames = ["2player", "3player", "4player", "playervsai", "playervs3ai"]
    let maps = allMaps.map {
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
        let pageViewHeight = (view.height - pageViewY - 8) / 2 * (10.0 / 11.0) - 8
        let pageViewWidth = view.width - pageViewX - 8
        pageView = FSPagerView(frame: CGRect(x: pageViewX, y: pageViewY, width: pageViewWidth, height: pageViewHeight * 0.9))
        self.view.addSubview(pageView)
        pageView.transformer = FSPagerViewTransformer(type: .linear)
        pageView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pageView.delegate = self
        pageView.dataSource = self
        let itemLength = min(pageViewWidth * 0.7, pageViewHeight)
        pageView.itemSize = CGSize(width: itemLength, height: itemLength)
        pageView.isInfinite = true
        
        let pageControlHeight = min(pageViewHeight, pageViewWidth) / 10
        let pageControlY = pageView.frame.maxY
        pageControl = FSPageControl(frame: CGRect(x: pageViewX, y: pageControlY, width: pageViewWidth, height: pageControlHeight))
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = pageView.currentIndex
        pageControl.setStrokeColor(.black, for: .normal)
        pageControl.setStrokeColor(.black, for: .selected)
        pageControl.setFillColor(.clear, for: .normal)
        pageControl.setFillColor(.black, for: .selected)
        self.view.addSubview(pageControl)
        
        mapPageView = FSPagerView(frame: CGRect(x: pageViewX, y: pageView.frame.maxY + pageControlHeight, width: pageViewWidth, height: pageViewHeight))
        self.view.addSubview(mapPageView)
        mapPageView.transformer = FSPagerViewTransformer(type: .linear)
        mapPageView.register(UINib(nibName: "GameBoardCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        mapPageView.delegate = self
        mapPageView.dataSource = self
        mapPageView.itemSize = pageView.itemSize
        mapPageView.isInfinite = true
        
        mapPageControl = FSPageControl(frame: CGRect(x: pageViewX, y: mapPageView.frame.maxY, width: pageViewWidth, height: pageControlHeight))
        mapPageControl.numberOfPages = maps.count
        mapPageControl.currentPage = mapPageView.currentIndex
        mapPageControl.setStrokeColor(.black, for: .normal)
        mapPageControl.setStrokeColor(.black, for: .selected)
        mapPageControl.setFillColor(.clear, for: .normal)
        mapPageControl.setFillColor(.black, for: .selected)
        self.view.addSubview(mapPageControl)
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        let longStartButton = (view.width - 24) / 2 >= backButton.width * 2
        let startButtonWidth = longStartButton ? backButton.width * 2 : backButtonWidth
        let startButtonX = view.width - 8 - startButtonWidth
        let startButtonText = longStartButton ? "START GAME" : "START"
        let startButton = PressableButton(frame: CGRect(x: startButtonX, y: backButtonY, width: startButtonWidth, height: backButtonHeight))
        let startFontSize = fontSizeThatFits(size: startButton.frame.size, text: startButtonText as NSString, font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        startButton.setAttributedTitle(
            NSAttributedString(string: startButtonText, attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: startFontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        startButton.colors = PressableButton.ColorSet(button: UIColor.green.desaturated().darker(), shadow: UIColor.green.desaturated().darker().darker())
        startButton.shadowHeight = startButton.height * 0.1
        self.view.addSubview(startButton)
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionViews()
    }
    
    override func viewDidLoad() {
        if arc4random_uniform(100) < 30 {
            shouldShowAd = true
            interstitial = GADInterstitial(adUnitID: adUnitID)
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            interstitial.delegate = self
            interstitial.load(request)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            [weak self] in
            self?.repositionViews()
        }
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func start() {
        if mapPageView.currentIndex > 3 && !UserDefaults.standard.bool(forKey: "mapsUnlocked") {
            promptUnlockMaps()
            return
        }
        if pageView.currentIndex < 3 {
            performSegue(withIdentifier: "showGame", sender: pageView.currentIndex + 2)
        }
        if pageView.currentIndex == 3 {
            performSegue(withIdentifier: "showAIGame", sender: (1, 1))
        }
        if pageView.currentIndex == 4 {
            performSegue(withIdentifier: "showAIGame", sender: (1, 3))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AIGameViewController {
            let tuple = sender as! (Int, Int)
            vc.aiCount = tuple.1
            vc.playerCount = tuple.0
            vc.map = maps[mapPageView.currentIndex]
        } else if let vc = segue.destination as? GameViewController {
            vc.playerCount = sender as! Int
            vc.map = maps[mapPageView.currentIndex]
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        performSegue(withIdentifier: "showAIGame", sender:(0, 4))
    }
}

extension PlayerCountSelectorController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        guard shouldShowAd else { return }
        ad.present(fromRootViewController: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldShowAd = false
    }
}

extension PlayerCountSelectorController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if pagerView == pageView {
            return imageNames.count
        } else {
            return maps.count
        }
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if pagerView == pageView {
            cell.imageView?.image = UIImage(named: imageNames[index])
        } else {
            let gameBoardCell = cell as! GameBoardCell
            gameBoardCell.game = Game(map: maps[index], playerCount: 4)
            gameBoardCell.locked = index > 3 && !UserDefaults.standard.bool(forKey: "mapsUnlocked")
        }
        cell.imageView?.contentMode = .scaleAspectFit
        cell.contentView.layer.shadowRadius = 0
        return cell
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        if pagerView == pageView {
            pageControl.currentPage = pagerView.currentIndex
        } else {
            mapPageControl.currentPage = pagerView.currentIndex
        }
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
            self?.productRequest = SKProductsRequest(productIdentifiers: [unlockAllMapsProductID])
            self?.productRequest.delegate = self
            self?.productRequest.start()
            EZLoadingActivity.show("Loading...", disableUI: true)
        }
        alert.addButton("Cancel", action: {})
        alert.showInfo("This map is locked!", subTitle: "Do you want to unlock all locked maps?", circleIconImage: #imageLiteral(resourceName: "lockedIcon"))
    }
}

extension PlayerCountSelectorController: SKProductsRequestDelegate {
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
            alert.addButton("Cancel", action: {})
            alert.showInfo("Unlock All Maps", subTitle: "Do you want to unlock all locked maps for \(price!)?", circleIconImage: #imageLiteral(resourceName: "lockedIcon"))
        } else {
            showIAPError(message: "Unable to get product information. Please check your Internet connection.")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        EZLoadingActivity.hide()
        showIAPError(message: "Unable to get product information. Please check your Internet connection.")
    }
    
    func showIAPError(message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("OK", action: {})
        alert.showError("Oops!", subTitle: message)
    }
}

extension PlayerCountSelectorController: SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        EZLoadingActivity.hide()
        if queue.transactions.isEmpty {
            showIAPError(message: "You have not purcheased this yet, so you cannot restore this purchase!")
        } else {
            UserDefaults.standard.set(true, forKey: "mapsUnlocked")
            pageView.reloadData()
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("OK", action: {})
            alert.showSuccess("Success!", subTitle: "All maps are now unlocked!")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        EZLoadingActivity.hide()
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    UserDefaults.standard.set(true, forKey: "mapsUnlocked")
                    pageView.reloadData()
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("OK", action: {})
                    alert.showSuccess("Success!", subTitle: "All maps are now unlocked!")
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    showIAPError(message: "Unable to purchase. Please check your Internet connection.")
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default: break
                }
            }
        }
    }
}
