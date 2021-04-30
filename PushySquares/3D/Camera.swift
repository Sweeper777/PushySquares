import SceneKit

class HorizontalPivotCamera {
    private let target: SCNNode
    private let cameraNode: SCNNode
    private let radius: Float
    private var angle: CGFloat = 0

    init(target: SCNNode, cameraNode: SCNNode) {
        self.target = target
        self.cameraNode = cameraNode
        radius = hypotf(target.position.x - cameraNode.position.x, target.position.z - cameraNode.position.z)
    }
}