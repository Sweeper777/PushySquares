import SceneKit
import PushySquaresModel

class BoardScene: SCNScene {
    var cameraNode: SCNNode!
    var board: BoardProvider?

    let cubeLength: CGFloat = 0.9

    func setup() {
        setupCamera()
        setupBoard()

        addLight(position: SCNVector3(-10, 10, -10))
        addLight(position: SCNVector3(-10, 10, 20))
        addLight(position: SCNVector3(20, 10, 20))
        addLight(position: SCNVector3(20, 10, -10))
    }

    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.position.y = 10
        cameraNode.eulerAngles.x = -0.523599
        cameraNode.eulerAngles.y = -.pi / 2
    }

    private func setupBoard() {
        guard let board = board else { return }

    }

    func addLight(position: SCNVector3) {
        let lightNode = SCNNode()
        lightNode.position = position
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        rootNode.addChildNode(lightNode)
    }
}
