import UIKit


class ViewAnimationPhase: AnimationPhase {

    let duration: TimeInterval
    static let invisibleScale: CGFloat = 0.000001

    var onEnd: (() -> Void)?

    func start(animations: [AnimationType: [UIView]]) {
    }

    private func animationBlock(for type: AnimationType) -> (UIView) -> Void {
        switch type {
        case .move(let dx, let dy):
            return { $0.frame = $0.frame.applying(CGAffineTransform(translationX: dx.f, y: dy.f)) }
        case .fall:
            return { $0.transform = CGAffineTransform(scaleX: ViewAnimationPhase.invisibleScale, y: ViewAnimationPhase.invisibleScale) }
        case .grayOut:
            return { $0.backgroundColor = .gray }
        case .newSquare:
            return { $0.transform = CGAffineTransform(scaleX: 1, y: 1) }
        }
    }

    required init(duration: TimeInterval) {
        self.duration = duration
    }

    typealias AnimatedObject = UIView

}
