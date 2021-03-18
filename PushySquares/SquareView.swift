import UIKit
import SwiftyUtils

class SquareView : UIView{

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: Foundation.NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
    }
}
