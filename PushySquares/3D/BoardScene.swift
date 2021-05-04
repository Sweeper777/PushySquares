import SceneKit
import PushySquaresModel

class BoardScene: SCNScene, BoardDisplayer {

    var cameraNode: SCNNode!
    var cameraPivot: SCNVector3!
    var cameraController: HorizontalPivotCamera!
    private var animationManager = AnimationManager<SceneAnimationPhase>()
    var board: BoardProvider! {
        didSet {
            refreshBoardNodes()
        }
    }

    let cubeLength: CGFloat = 0.88
    let cubeChamferRadius: CGFloat = 0.1
    let cubeNodeNamePrefix = "square"
    let arrowRadius: CGFloat = 1
    let arrowHeight: CGFloat = 0.5

    private lazy var trianglePath = { () -> UIBezierPath in
        let triangle = UIBezierPath()
        triangle.move(to: CGPoint(x: 0, y: -arrowRadius))
        triangle.addLine(to: CGPoint(x: arrowRadius * sin(degreesToRadians(120)), y: -arrowRadius * cos(degreesToRadians(120))))
        triangle.addLine(to: CGPoint(x: arrowRadius * sin(degreesToRadians(240)), y: -arrowRadius * cos(degreesToRadians(240))))
        triangle.close()
        return triangle
    }()

    var delegate: BoardDisplayerDelegate?
    private weak var target: AnyObject?
    private var upSelector: Selector?
    private var downSelector: Selector?
    private var leftSelector: Selector?
    private var rightSelector: Selector?

    func setTarget(_ target: AnyObject,
                   moveUp: Selector,
                   moveDown: Selector,
                   moveLeft: Selector,
                   moveRight: Selector) {
        self.target = target
        upSelector = moveUp
        downSelector = moveDown
        leftSelector = moveLeft
        rightSelector = moveRight
    }

    func setup(with mapTiles: Array2D<MapTile>) {
        setupCamera(mapTiles)
//        setupFloor()
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

        let cameraPivotNode = SCNNode()
        cameraPivotNode.position = cameraPivot
        rootNode.addChildNode(cameraPivotNode)
        cameraController = .init(target: cameraPivotNode, cameraNode: cameraNode)
    }

    private func setupBoard(_ mapTiles: Array2D<MapTile>) {

        for x in 0..<mapTiles.columns {
            for y in 0..<mapTiles.rows {
                guard let material = MapTileTextureGenerator.material(for: mapTiles[x, y]) else { continue }
                let otherSides = MapTileTextureGenerator.material(for: UIColor(hex: "fff4cc"))
                let boardGeometry = SCNBox(width: 1, height: CGFloat(SceneAnimationPhase.fallHeight * 5), length: 1, chamferRadius: 0)
                boardGeometry.materials = [
                    otherSides, otherSides, otherSides, otherSides, material, otherSides
                ]
                let tileNode = SCNNode(geometry: boardGeometry)
                tileNode.position = SCNVector3(x, 0, y)
                tileNode.pivot = SCNMatrix4MakeTranslation(0, SceneAnimationPhase.fallHeight * 5 / 2, 0)
                rootNode.addChildNode(tileNode)
                if mapTiles[x, y] == .wall {
                    let wallNode = makeCubeNode(withColor: .white)
                    wallNode.position = SCNVector3(x, 0, y)
                    rootNode.addChildNode(wallNode)
                }
            }
        }
    }

    private func setupFloor() {
        let floorGeometry = SCNFloor()
        floorGeometry.firstMaterial = SCNMaterial()
        floorGeometry.firstMaterial?.diffuse.contents = UIImage(named: "grass")
//        floorGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(32, 32, 0)
        floorGeometry.firstMaterial?.diffuse.wrapS = .repeat
        floorGeometry.firstMaterial?.diffuse.wrapT = .repeat
        let floor = SCNNode(geometry: floorGeometry)
        floor.position.y = -SceneAnimationPhase.fallHeight
        rootNode.addChildNode(floor)
    }

    private func setupArrows(_ mapTiles: Array2D<MapTile>) {
        let centerX = determineMidpoint(mapTiles.columns)
        let centerZ = determineMidpoint(mapTiles.rows)
        let upArrow = makeArrowNode()
        upArrow.position = SCNVector3(centerX, 0, -1)
        upArrow.eulerAngles.y = 0
        upArrow.name = "up arrow"
        rootNode.addChildNode(upArrow)

        let downArrow = makeArrowNode()
        downArrow.position = SCNVector3(centerX, 0, mapTiles.rows.f)
        downArrow.eulerAngles.y = .pi
        downArrow.name = "down arrow"
        rootNode.addChildNode(downArrow)

        let leftArrow = makeArrowNode()
        leftArrow.position = SCNVector3(-1, 0, centerZ)
        leftArrow.eulerAngles.y = .pi / 2
        leftArrow.name = "left arrow"
        rootNode.addChildNode(leftArrow)

        let rightArrow = makeArrowNode()
        rightArrow.position = SCNVector3(mapTiles.columns.f, 0, centerZ)
        rightArrow.eulerAngles.y = -.pi / 2
        rightArrow.name = "right arrow"
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

    private func cubeNode(atPosition position: Position) -> SCNNode? {
        rootNode.childNode(withName: nameForSquare(atX: position.x, y: position.y), recursively: false)
    }

    func animateMoveResult(_ moveResult: MoveResult) {
        animationManager.reset()
        let dx: Double
        let dy: Double
        switch moveResult.direction {
        case .right:
            (dx, dy) = (1, 0)
        case .left:
            (dx, dy) = (-1, 0)
        case .down:
            (dx, dy) = (0, 1)
        case .up:
            (dx, dy) = (0, -1)
        }

        let movedSquares = moveResult.movedPositions.compactMap(cubeNode(atPosition:))
        let slippedSquares = moveResult.slippedPositions.compactMap(cubeNode(atPosition:))
        let fellSquares = moveResult.fellPositions.compactMap(cubeNode(atPosition:))
        let grayedOutSquares = moveResult.greyedOutPositions.compactMap(cubeNode(atPosition:))
        if movedSquares.isNotEmpty || slippedSquares.isNotEmpty {
            animationManager.addPhase(group: [
                .move(dx: Double(dx), dy: Double(dy)): movedSquares,
                .move(dx: Double(dx) * 2, dy: Double(dy) * 2): slippedSquares
            ], duration: 0.5, completion: nil)
        }
        if fellSquares.isNotEmpty {
            animationManager.addPhase(group: [.fall: fellSquares], duration: 0.5) {
                fellSquares.forEach {
                    $0.removeFromParentNode()
                }
            }
        }
        if grayedOutSquares.isNotEmpty {
            animationManager.addPhase(group: [.grayOut: grayedOutSquares], duration: 0.5, completion: nil)
        }
        if let (color, position) = moveResult.newSquare {
            let newSquare = makeCubeNode(withColor: BoardView.colorToUIColor[color]!)
            newSquare.position.x = Float(position.x)
            newSquare.position.z = Float(position.y)
            newSquare.scale = SCNVector3(SceneAnimationPhase.invisibleScale, SceneAnimationPhase.invisibleScale, SceneAnimationPhase.invisibleScale)
            newSquare.name = nameForSquare(atX: position.x, y: position.y)
            rootNode.addChildNode(newSquare)
            animationManager.addPhase(group: [.newSquare: [newSquare]], duration: 0.5, completion: nil)
        }
        animationManager.runAnimation { [weak self] in
            guard let `self` = self else { return }
            let displace = moveResult.direction.displacementFunction
            (movedSquares).forEach {
                let newPosition = displace(self.positionFromSquareName($0.name!))
                $0.name = self.nameForSquare(atX: newPosition.x, y: newPosition.y)
            }
            (slippedSquares).forEach {
                let newPosition = displace(displace(self.positionFromSquareName($0.name!)))
                $0.name = self.nameForSquare(atX: newPosition.x, y: newPosition.y)
            }
            self.delegate?.boardDidEndAnimatingMoveResult(self, moveResult: moveResult)
        }
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
        let geometry = SCNShape(path: trianglePath, extrusionDepth: arrowHeight)
        geometry.chamferRadius = cubeChamferRadius
        geometry.firstMaterial = MapTileTextureGenerator.material(for: .black)
        let arrow = SCNNode(geometry: geometry)
        arrow.eulerAngles.x = .pi / 2
        arrow.pivot = SCNMatrix4MakeTranslation(0, Float(arrowRadius), Float(arrowHeight / 2))
        return arrow
    }

    func nameForSquare(atX x: Int, y: Int) -> String {
        "\(cubeNodeNamePrefix) \(x) \(y)"
    }

    func positionFromSquareName(_ name: String) -> Position {
        let components = name.components(separatedBy: " ")
        return Position(Int(components[1])!, Int(components[2])!)
    }

    func rotateCamera(_ dTheta: Float) {
        cameraController.pivot(dTheta)
    }

    func onTap(_ results: [SCNHitTestResult]) -> Bool {
        if let firstResult = results.first {
            let selectorToPerform: Selector?
            switch firstResult.node.name {
            case "up arrow":
                selectorToPerform = upSelector
            case "down arrow":
                selectorToPerform = downSelector
            case "left arrow":
                selectorToPerform = leftSelector
            case "right arrow":
                selectorToPerform = rightSelector
            default:
                selectorToPerform = nil
            }
            if let target = target, let sel = selectorToPerform {
                _ = target.perform(sel)
            }
            return selectorToPerform != nil
        }
        return false
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