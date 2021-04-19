import UIKit
import FSPagerView
import PushySquaresModel
import SCLAlertView
import StoreKit
import EZLoadingActivity

protocol HasMapSelector : SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var mapSelector: FSPagerView! { get }
    var mapSelectorPageControl: FSPageControl! { get }
    var maps: [Map] { get }
    var mapSelectorDelegate: MapSelectorDelegate { get }
    var productRequest: SKProductsRequest! { get set }
}

extension HasMapSelector {
    func setupMapSelector() {
        mapSelector.register(UINib(nibName: "GameBoardCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        mapSelector.transformer = FSPagerViewTransformer(type: .linear)
        mapSelectorPageControl.numberOfPages = maps.count
        mapSelectorPageControl.currentPage = mapSelector.currentIndex
        mapSelectorPageControl.setStrokeColor(.black, for: .normal)
        mapSelectorPageControl.setStrokeColor(.black, for: .selected)
        mapSelectorPageControl.setFillColor(.clear, for: .normal)
        mapSelectorPageControl.setFillColor(.black, for: .selected)
        mapSelector.delegate = mapSelectorDelegate
        mapSelector.dataSource = mapSelectorDelegate
    }

    var mapUnlocked: Bool {
        mapSelector.currentIndex <= 3 || UserDefaults.standard.bool(forKey: mapsUnlockedKey)
    }

    func updateMapSelectorItemSize() {
        let pageViewWidth = mapSelector.width
        let pageViewHeight = mapSelector.height
        let itemSideLength = min(pageViewWidth, pageViewHeight) * 0.7
        mapSelector.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
    }

    func promptUnlockMaps() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Unlock All Maps".localized) { [weak self] in
            self?.productRequest = SKProductsRequest(productIdentifiers: [unlockAllMapsProductID])
            self?.productRequest.delegate = self
            self?.productRequest.start()
            EZLoadingActivity.show("Loading...".localized, disableUI: true)
        }
        alert.addButton("Cancel".localized, action: {})
        alert.showInfo("This map is locked!".localized, subTitle: "Do you want to unlock all locked maps?".localized, circleIconImage: #imageLiteral(resourceName: "lockedicon"))
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        EZLoadingActivity.hide()
        if let product = response.products.first {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            let price = numberFormatter.string(from: product.price)
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton(String(format: "Unlock All Maps for %@".localized, price!)) { [weak self] in
                guard let `self` = self else { return }
                if SKPaymentQueue.canMakePayments() {
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(SKPayment(product: product))
                    EZLoadingActivity.show("Loading...".localized, disableUI: true)
                } else {
                    self.showIAPError(message: "Purchases are disabled on this device!".localized)
                }
            }
            alert.addButton("Restore Purchase".localized) { [weak self] in
                guard let `self` = self else { return }
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
                EZLoadingActivity.show("Loading...".localized, disableUI: true)
            }
            alert.addButton("Cancel".localized, action: {})
            alert.showInfo("Unlock All Maps".localized, subTitle: String(format: "Do you want to unlock all locked maps for %@?".localized, price!), circleIconImage: #imageLiteral(resourceName: "lockedIcon"))
        } else {
            showIAPError(message: "Unable to get product information. Please check your Internet connection.".localized)
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        EZLoadingActivity.hide()
        showIAPError(message: "Unable to get product information. Please check your Internet connection.".localized)
    }

    func showIAPError(message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("OK".localized, action: {})
        alert.showError("Oops!".localized, subTitle: message)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        EZLoadingActivity.hide()
        if queue.transactions.isEmpty {
            showIAPError(message: "You have not purcheased this yet, so you cannot restore this purchase!".localized)
        } else {
            UserDefaults.standard.set(true, forKey: "mapsUnlocked")
            mapSelector.reloadData()
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("OK".localized, action: {})
            alert.showSuccess("Success!".localized, subTitle: "All maps are now unlocked!".localized)
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
                    mapSelector.reloadData()
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("OK".localized, action: {})
                    alert.showSuccess("Success!".localized, subTitle: "All maps are now unlocked!".localized)
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    showIAPError(message: "Unable to purchase. Please check your Internet connection.".localized)
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default: break
                }
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}