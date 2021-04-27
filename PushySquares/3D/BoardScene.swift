import SceneKit
import PushySquaresModel

class BoardScene: SCNScene, BoardDisplayer {

    var cameraNode: SCNNode!
    var cameraPivot: SCNVector3!
    var board: BoardProvider! {
        didSet {
            refreshBoardNodes()
        }
    }

    let cubeLength: CGFloat = 0.88
    let cubeChamferRadius: CGFloat = 0.1
    let cubeNodeNamePrefix = "square"

    var delegate: BoardViewDelegate?

    func setup(with mapTiles: Array2D<MapTile>) {
        setupCamera(mapTiles)
        setupBoard(mapTiles)

        addLight(position: SCNVector3(0, 10, 0))
        addLight(position: SCNVector3(mapTiles.columns, 10, 0))
        addLight(position: SCNVector3(0, 10, mapTiles.rows))
        addLight(position: SCNVector3(mapTiles.columns, 10, mapTiles.rows))

        let triangle = UIBezierPath()
        triangle.move(to: CGPoint(x: 0, y: -2))
        triangle.addLine(to: CGPoint(x: 2 * sin(degreesToRadians(120)), y: -2 * cos(degreesToRadians(120))))
        triangle.addLine(to: CGPoint(x: 2 * sin(degreesToRadians(240)), y: -2 * cos(degreesToRadians(240))))
        triangle.close()
        let geometry = SCNShape(path: triangle, extrusionDepth: 1)
        geometry.chamferRadius = cubeChamferRadius
        geometry.firstMaterial = MapTileTextureGenerator.material(for: .red)
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(x: 1, y: 0, z: 1)
        rootNode.addChildNode(node)
    }

    private func setupCamera(_ mapTiles: Array2D<MapTile>) {
        cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera

        let boardRadius = mapTiles.columns.f / 2
        let cameraDistance = boardRadius / tan(degreesToRadians(camera.fieldOfView) / 2) * 1
        let centerX = determineMidpoint(mapTiles.columns)
        let centerZ = determineMidpoint(mapTiles.rows)
        let cameraHeight: Float = 10

        cameraNode.position = SCNVector3(x: Float(centerX), y: cameraHeight, z: Float(mapTiles.rows.f + cameraDistance))
        cameraPivot = SCNVector3(x: Float(centerX), y: cameraHeight, z: Float(centerZ))

        cameraNode.eulerAngles.x = -0.5
    }

    private func setupBoard(_ mapTiles: Array2D<MapTile>) {
        for x in 0..<mapTiles.columns {
            for y in 0..<mapTiles.rows {
                guard let material = MapTileTextureGenerator.material(for: mapTiles[x, y]) else { continue }
                let black = MapTileTextureGenerator.material(for: UIColor.black)
                let boardGeometry = SCNBox(width: 1, height: 0.1, length: 1, chamferRadius: 0)
                boardGeometry.materials = [
                    black, black, black, black, material, black
                ]
                let tileNode = SCNNode(geometry: boardGeometry)
                tileNode.position = SCNVector3(x, 0, y)
                rootNode.addChildNode(tileNode)
                if mapTiles[x, y] == .wall {
                    let wallNode = cubeNode(withColor: .white)
                    wallNode.position = SCNVector3(x, 0, y)
                    rootNode.addChildNode(wallNode)
                }
            }
        }
    }

    private func refreshBoardNodes() {
        guard let boardState = board?.boardState else { return }

        rootNode.enumerateChildNodes { node, _ in
            if (node.name ?? "").hasPrefix(cubeNodeNamePrefix) {
                node.removeFromParentNode()
            }
        }

        for x in 0..<boardState.columns {
            for y in 0..<boardState.rows {
                let cube: SCNNode
                switch boardState[x, y] {
                case .empty:
                    continue
                case .square(let color):
                    cube = cubeNode(withColor: BoardView.colorToUIColor[color]!)
                case .deadBody:
                    cube = cubeNode(withColor: .gray)
                }
                cube.name = nameForSquare(atX: x, y: y)
                cube.position = SCNVector3(x.f, 0, y.f)
                rootNode.addChildNode(cube)
            }
        }
    }

    func addLight(position: SCNVector3) {
        let lightNode = SCNNode()
        lightNode.position = position
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 300
        rootNode.addChildNode(lightNode)
    }

    func animateMoveResult(_ moveResult: MoveResult) {

    }

    func cubeNode(withColor color: UIColor) -> SCNNode {
        let colorMaterial = MapTileTextureGenerator.material(for: color)
        let boardGeometry = SCNBox(width: cubeLength, height: cubeLength, length: cubeLength, chamferRadius: cubeChamferRadius)
        boardGeometry.firstMaterial = colorMaterial
        let node = SCNNode(geometry: boardGeometry)
        node.pivot = SCNMatrix4MakeTranslation(0, -0.4998, 0)
        return node
    }

    func nameForSquare(atX x: Int, y: Int) -> String {
        "\(cubeNodeNamePrefix) \(x) \(y)"
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