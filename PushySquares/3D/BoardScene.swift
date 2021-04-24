import SceneKit
import PushySquaresModel

class BoardScene: SCNScene, BoardDisplayer {

    var cameraNode: SCNNode!
    var board: BoardProvider!

    let cubeLength: CGFloat = 0.9

    var delegate: BoardViewDelegate?

    func setup(with mapTiles: Array2D<MapTile>) {
        setupCamera(mapTiles)
        setupBoard(mapTiles)

//        addLight(position: SCNVector3(-10, 10, -10))
//        addLight(position: SCNVector3(-10, 10, 20))
        addLight(position: SCNVector3(20, 10, 20))
        addLight(position: SCNVector3(20, 10, -10))
    }

    private func setupCamera(_ mapTiles: Array2D<MapTile>) {
        cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera

        let boardRadius = mapTiles.columns.f / 2
        let cameraDistance = boardRadius / tan(degreesToRadians(camera.fieldOfView) / 2) * 1.2
        let cameraX = determineMidpoint(mapTiles.columns)
        let cameraZ = determineMidpoint(mapTiles.rows)

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

    func animateMoveResult(_ moveResult: MoveResult) {

    }
}

func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
    degrees / 180 * .pi
}

func determineMidpoint(_ length: Int) -> CGFloat {
    if length % 2 == 1 {
        return (length / 2).f
    } else {
        return length.f / 2 - 0.5
    }
}