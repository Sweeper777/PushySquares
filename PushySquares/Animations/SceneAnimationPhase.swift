import SceneKit

class SceneAnimationPhase : AnimationPhase {
    var duration: TimeInterval
    static let invisibleScale: Float = 0.000001

    var onEnd: (() -> Void)?

    func start(animations: [AnimationType: [SCNNode]]) {
    }


    required init(duration: TimeInterval) {
        self.duration = duration
    }

    typealias AnimatedObject = SCNNode
}
