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
    private lazy var trianglePath = { () -> UIBezierPath in
        let triangle = UIBezierPath()
        triangle.move(to: CGPoint(x: 0, y: -2))
        triangle.addLine(to: CGPoint(x: 2 * sin(degreesToRadians(120)), y: -2 * cos(degreesToRadians(120))))
        triangle.addLine(to: CGPoint(x: 2 * sin(degreesToRadians(240)), y: -2 * cos(degreesToRadians(240))))
        triangle.close()
        return triangle
    }()

    var delegate: BoardViewDelegate?

    func setup(with mapTiles: Array2D<MapTile>) {
        setupCamera(mapTiles)
        setupBoard(mapTiles)
        setupArrows(mapTiles)

        addLight(position: SCNVector3(0, 10, 0))
        addLight(position: SCNVector3(mapTiles.columns, 10, 0))
        addLight(position: SCNVector3(0, 10, mapTiles.rows))
        addLight(position: SCNVector3(mapTiles.columns, 10, mapTiles.rows))
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

        cameraNode.eulerAngles.x = -0.7
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
                    let wallNode = makeCubeNode(withColor: .white)
                    wallNode.position = SCNVector3(x, 0, y)
                    rootNode.addChildNode(wallNode)
                }
            }
        }
    }

    private func setupArrows(_ mapTiles: Array2D<MapTile>) {
        let centerX = determineMidpoint(mapTiles.columns)
        let centerZ = determineMidpoint(mapTiles.rows)
        let upArrow = makeArrowNode()
        upArrow.position = SCNVector3(centerX, 0, -1)
        upArrow.eulerAngles.y = 0
        rootNode.addChildNode(upArrow)

        let downArrow = makeArrowNode()
        downArrow.position = SCNVector3(centerX, 0, mapTiles.rows.f)
        downArrow.eulerAngles.y = .pi
        rootNode.addChildNode(downArrow)

        let leftArrow = makeArrowNode()
        leftArrow.position = SCNVector3(-1, 0, centerZ)
        leftArrow.eulerAngles.y = .pi / 2
        rootNode.addChildNode(leftArrow)

        let rightArrow = makeArrowNode()
        rightArrow.position = SCNVector3(mapTiles.columns.f, 0, centerZ)
        rightArrow.eulerAngles.y = -.pi / 2
        rootNode.addChildNode(rightArrow)
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
                    cube = makeCubeNode(withColor: BoardView.colorToUIColor[color]!)
                case .deadBody:
                    cube = makeCubeNode(withColor: .gray)
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

    func makeCubeNode(withColor color: UIColor) -> SCNNode {
        let colorMaterial = MapTileTextureGenerator.material(for: color)
        let boardGeometry = SCNBox(width: cubeLength, height: cubeLength, length: cubeLength, chamferRadius: cubeChamferRadius)
        boardGeometry.firstMaterial = colorMaterial
        let node = SCNNode(geometry: boardGeometry)
        node.pivot = SCNMatrix4MakeTranslation(0, -0.4998, 0)
        return node
    }

    func makeArrowNode() -> SCNNode {
        let geometry = SCNShape(path: trianglePath, extrusionDepth: 1)
        geometry.chamferRadius = cubeChamferRadius
        geometry.firstMaterial = MapTileTextureGenerator.material(for: .black)
        let arrow = SCNNode(geometry: geometry)
        arrow.eulerAngles.x = .pi / 2
        arrow.pivot = SCNMatrix4MakeTranslation(0, 2, 0.5)
        return arrow
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