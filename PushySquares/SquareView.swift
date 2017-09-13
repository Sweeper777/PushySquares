import UIKit
import SwiftyUtils
import DynamicColor
import SwiftyAnimate

@IBDesignable
class SquareView: UIView {
    static var animDuration: TimeInterval = 0.5
    
    override func draw(_ rect: CGRect) {
        let strokeWidth = self.width / 8
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.width - strokeWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: self.width - strokeWidth / 2, y: self.height - strokeWidth / 2))
        path.addLine(to: CGPoint(x: 0, y: self.height - strokeWidth / 2))
        self.backgroundColor?.darker().setStroke()
        path.lineWidth = strokeWidth
        path.stroke()
    }
    
    var moveUp: Animate {
        return Animate(duration: SquareView.animDuration, delay: 0, options: [.curveEaseInOut]) {
            [weak self] in
            guard let `self` = self else { return }
            let superView = self.superview as! GameBoardView
            self.tag = superView.position(forViewTag: self.tag).above().hashValue
            self.frame = self.frame.with(origin: superView.squareViewPoint(for: superView.position(forViewTag: self.tag)))
        }
    }
    
    var moveDown: Animate {
        return Animate(duration: SquareView.animDuration, delay: 0, options: [.curveEaseInOut]) {
            [weak self] in
            guard let `self` = self else { return }
            let superView = self.superview as! GameBoardView
            self.tag = superView.position(forViewTag: self.tag).below().hashValue
            self.frame = self.frame.with(origin: superView.squareViewPoint(for: superView.position(forViewTag: self.tag)))
        }
    }
    
    var moveLeft: Animate {
        return Animate(duration: SquareView.animDuration, delay: 0, options: [.curveEaseInOut]) {
            [weak self] in
            guard let `self` = self else { return }
            let superView = self.superview as! GameBoardView
            self.tag = superView.position(forViewTag: self.tag).left().hashValue
            self.frame = self.frame.with(origin: superView.squareViewPoint(for: superView.position(forViewTag: self.tag)))
        }
    }
    
    var moveRight: Animate {
        return Animate(duration: SquareView.animDuration, delay: 0, options: [.curveEaseInOut]) {
            [weak self] in
            guard let `self` = self else { return }
            let superView = self.superview as! GameBoardView
            self.tag = superView.position(forViewTag: self.tag).right().hashValue
            self.frame = self.frame.with(origin: superView.squareViewPoint(for: superView.position(forViewTag: self.tag)))
        }
    }
    
    var destroyed: Animate {
        return transform(duration: SquareView.animDuration, transforms: [
            .scale(x: 0, y: 0)
            ]).do { [weak self] in
                self?.removeFromSuperview()
        }
    }
    
    var appear: Animate {
        return Animate(duration: SquareView.animDuration) {
            [weak self] in
            self?.alpha = 1
        }
    }
}
