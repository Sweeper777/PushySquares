import SceneKit

class SceneAnimationPhase : AnimationPhase {
    var duration: TimeInterval
    static let invisibleScale: Float = 0.000001

    var onEnd: (() -> Void)?

    func start(animations: [AnimationType: [SCNNode]]) {
    }

    func block(forAnimationType animationType: AnimationType) -> (SCNNode) -> Void {
        switch animationType {
        case .move(dx: let dx, dy: let dy):
            return { node in
                node.position.x += Float(dx)
                node.position.z += Float(dy)
            }
        case .fall:
            return { $0.position.y -= 10 }
        case .grayOut:
            return { $0.geometry?.firstMaterial?.diffuse.contents = UIColor.gray }
        case .newSquare:
            return { $0.scale = SCNVector3(1, 1, 1) }
        }
    }

    required init(duration: TimeInterval) {
        self.duration = duration
    }

    typealias AnimatedObject = SCNNode
}
