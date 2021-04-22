import UIKit


class ViewAnimationPhase: AnimationPhase {

    let duration: TimeInterval
    static let invisibleScale: CGFloat = 0.000001

    var onEnd: (() -> Void)?

    func start(animations: [AnimationType: [UIView]]) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            guard let `self` = self else { return }
            for (type, views) in animations {
                let block = self.animationBlock(for: type)
                views.forEach(block)
            }
        }, completion: { [weak self] _ in self?.onEnd?() })
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
