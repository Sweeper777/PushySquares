import SceneKit

class HorizontalPivotCamera {
    private let target: SCNNode
    private let cameraNode: SCNNode
    private let radius: Float
    private var angle: Float
    private var eulerY: Float

    init(target: SCNNode, cameraNode: SCNNode) {
        self.target = target
        self.cameraNode = cameraNode
        radius = hypotf(target.position.x - cameraNode.position.x, target.position.z - cameraNode.position.z)
        angle = atan2f(cameraNode.position.z - target.position.z, cameraNode.position.x - target.position.x)
        eulerY = cameraNode.eulerAngles.y
    }

    func pivot(_ radians: Float) {
        angle += radians
        eulerY -= radians
        angle.formRemainder(dividingBy: 2 * .pi)
        updateCameraPosition()
    }

    private func updateCameraPosition() {
        cameraNode.position.x = target.position.x + radius * cos(angle)
        cameraNode.position.z = target.position.z + radius * sin(angle)
        cameraNode.eulerAngles.y = eulerY
    }
}