import UIKit
import SwiftyUtils

class SquareView : UIView{

    var shadowLayer: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: Foundation.NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        addShadowLayer()
    }

    func addShadowLayer() {
        let strokeWidth = self.width / 8
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.width - strokeWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: self.width - strokeWidth / 2, y: self.height - strokeWidth / 2))
        path.addLine(to: CGPoint(x: 0, y: self.height - strokeWidth / 2))
        shadowLayer = CAShapeLayer()
        shadowLayer.strokeColor = UIColor(white: 0, alpha: 0.3).cgColor
        shadowLayer.fillColor = UIColor.clear.cgColor
        shadowLayer.path = path.cgPath
        shadowLayer.lineWidth = strokeWidth
        layer.addSublayer(shadowLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowLayer.removeFromSuperlayer()
        addShadowLayer()
        var a = [1]
        a.remove(atOffsets: IndexSet())
    }
}
