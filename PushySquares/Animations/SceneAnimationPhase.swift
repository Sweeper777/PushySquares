import SceneKit

class SceneAnimationPhase : AnimationPhase {
    var duration: TimeInterval
    static let invisibleScale: Float = 0.000001
    static let fallHeight: Float = 10

    var onEnd: (() -> Void)?

    func start(animations: [AnimationType: [SCNNode]]) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.completionBlock = onEnd
        for (type, nodes) in animations {
            let transform = block(forAnimationType: type)
            for node in nodes {
                transform(node)
            }
        }
        SCNTransaction.commit()
    }

    func block(forAnimationType animationType: AnimationType) -> (SCNNode) -> Void {
        switch animationType {
        case .move(dx: let dx, dy: let dy):
            return { node in
                node.position.x += Float(dx)
                node.position.z += Float(dy)
            }
        case .fall:
            return { $0.position.y -= Self.fallHeight }
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
