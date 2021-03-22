import UIKit


class ViewAnimationPhase: AnimationPhase {

    let duration: TimeInterval
    static let invisibleScale: CGFloat = 0.000001

    var onEnd: (() -> Void)?

    func start(animations: [AnimationType: [UIView]]) {
    }


    required init(duration: TimeInterval) {
        self.duration = duration
    }

    typealias AnimatedObject = UIView

}
