public class Game : BoardProvider {
    static let playerCountToTurnsUntilNewSquare = [
        2: 2,
        3: 4,
        4: 4
    ]
    
    public let map: Array2D<MapTile>
    public internal(set) var boardState: Array2D<BoardState>
    public internal(set) var spawnpoints: [Color: Position]
    public internal(set) var players = [Player]()
    public var currentPlayer: Player {
        return players[currentPlayerIndex]
    }

    public var gameResult: GameResult {
        let remainingPlayers = players.filter { $0.lives > 0 }
        if remainingPlayers.count > 1 {
            return .unknown
        }
        if let solePlayerLeft = remainingPlayers.first {
            return .won(solePlayerLeft.color)
        }
        return .tie
    }
    
    private var currentPlayerIndex = 0
    
    public init(map: Map, playerCount: Int, lives: Int = 5) {
        self.map = map.board
        self.boardState = map.initialBoardState
        self.spawnpoints = map.spawnpoints
        
        switch playerCount {
        case 4:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .yellow))
            spawnNewSquare(color: .yellow)
            fallthrough
        case 3:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .blue))
            spawnNewSquare(color: .blue)
            fallthrough
        case 2:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .red))
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .green))
            spawnNewSquare(color: .red)
            spawnNewSquare(color: .green)
        default:
            fatalError()
        }
        
        players.sort { $0.color.rawValue < $1.color.rawValue }
        
        if playerCount < 4 {
            spawnpoints[.yellow] = nil
        }
        
        if playerCount < 3 {
            spawnpoints[.blue] = nil
        }
        
        currentPlayer.turnsUntilNewSquare -= 1
    }
    
    public init(game: Game) {
        self.boardState = game.boardState
        self.map = game.map
        self.spawnpoints = game.spawnpoints
        self.players = game.players.map { $0.createCopy() }
        self.currentPlayerIndex = game.currentPlayerIndex
    }

    @discardableResult
    public func moveUp() -> MoveResult {
        move(sortOrder: { $0.y < $1.y }, direction: .up)
    }

    @discardableResult
    public func moveDown() -> MoveResult {
        move(sortOrder: { $0.y > $1.y }, direction: .down)
    }

    @discardableResult
    public func moveLeft() -> MoveResult {
        move(sortOrder: { $0.x < $1.x }, direction: .left)
    }

    @discardableResult
    public func moveRight() -> MoveResult {
        move(sortOrder: { $0.x > $1.x }, direction: .right)
    }

    private func move(sortOrder: (Position, Position) -> Bool, direction: Direction) -> MoveResult {
        let displace = direction.displacementFunction
        let allSquaresPositions = boardState.indices(ofColor: currentPlayer.color)

        if allSquaresPositions.isEmpty {
            nextTurn()
            let newSquareColor = evaluateTurnsUntilNewSquare()
            return MoveResult(
                    direction: direction,
                    newSquare: newSquareColor.map { ($0, spawnpoints[$0]!) },
                    gameResult: gameResult
            )
        }

        var movingSquaresPositions = Set<Position>()
        var beingDestroyedSquaresPositions = Set<Position>()
        for position in allSquaresPositions {
            var pushedPositions = [position]
            loop: while true {
                switch (boardState[displace(pushedPositions.last!)], map[displace(pushedPositions.last!)]) {
                case (.empty, .ground), (.empty, .slippery), (.empty, .spawnpoint):
                    break loop
                case (_, .wall):
                    pushedPositions = []
                    break loop
                case (_, .void):
                    beingDestroyedSquaresPositions.insert(pushedPositions.last!)
                    break loop
                default:
                    pushedPositions.append(displace(pushedPositions.last!))
                }
            }
            movingSquaresPositions.formUnion(pushedPositions)
        }
        var slippedPositions = Set<Position>()

        for position in movingSquaresPositions {
            switch canSlip(in: direction, position: position) {
            case .fail:
                continue
            case .death:
                beingDestroyedSquaresPositions.insert(position)
                fallthrough
            case .success:
                slippedPositions.insert(position)
                movingSquaresPositions.remove(position)
            }
        }

        let sortedPositions = movingSquaresPositions.sorted(by: sortOrder)
        beingDestroyedSquaresPositions = Set(beingDestroyedSquaresPositions)

        let greyedOutSquaresPositions = handleDeaths(destroyedSquarePositions: beingDestroyedSquaresPositions)

        for position in slippedPositions + sortedPositions {
            let tile = boardState[position]
            boardState[position] = .empty
            if !beingDestroyedSquaresPositions.contains(position) {
                if slippedPositions.contains(position) {
                    boardState[displace(displace(position))] = tile
                } else {
                    boardState[displace(position)] = tile
                }
            }
        }
        nextTurn()
        let newSquareColor = evaluateTurnsUntilNewSquare()
        return MoveResult(
                direction: direction,
                movedPositions: movingSquaresPositions,
                slippedPositions: slippedPositions,
                fellPositions: beingDestroyedSquaresPositions,
                greyedOutPositions: greyedOutSquaresPositions,
                newSquare: newSquareColor.map { ($0, spawnpoints[$0]!) },
                gameResult: gameResult)
    }

    private func handleDeaths(destroyedSquarePositions: Set<Position>) -> Set<Position> {
        var retVal = Set<Position>()
        for player in players {
            let destroyedSquares = destroyedSquarePositions.filter {
                if case .square(player.color) = boardState[$0] {
                    return true
                } else {
                    return false
                }
            }
            player.lives -= destroyedSquares.count
            if player.lives == 0 {
                for pos in boardState.indices(ofColor: player.color) {
                    retVal.insert(pos)
                    boardState[pos] = .deadBody
                }
            }
        }
        return retVal
    }
    
    public func killPlayer(_ color: Color) {
        guard let index = players.firstIndex(where: { $0.color == color && $0.lives > 0 }) else { return }
        let player = players[index]
        player.lives = 0
        var greyedOutPositions = [Position]()
        for position in boardState.indices(ofColor: color) {
            boardState[position] = .deadBody
            greyedOutPositions.append(position)
        }
        
        if currentPlayer.color == color {
            nextTurn()
        }
        
    }
    
    private func nextTurn() {
        if (!players.contains { $0.lives > 0 }) {
            return
        }
        
        repeat {
            currentPlayerIndex = currentPlayerIndex == players.endIndex - 1 ? 0 : currentPlayerIndex + 1
        } while currentPlayer.lives == 0
    }

    private func evaluateTurnsUntilNewSquare() -> Color? {
        currentPlayer.turnsUntilNewSquare -= 1
        if currentPlayer.turnsUntilNewSquare == 0 {
            if boardState[spawnpoints[currentPlayer.color]!] == .empty {
                spawnNewSquare(color: currentPlayer.color)
                currentPlayer.turnsUntilNewSquare = Game.playerCountToTurnsUntilNewSquare[players.count]! + 1
                return currentPlayer.color
            }
            currentPlayer.turnsUntilNewSquare = Game.playerCountToTurnsUntilNewSquare[players.count]! + 1
        }
        return nil
    }
    
    private func canSlip(in direction: Direction, position: Position) -> SlipResult {
        let displace = direction.displacementFunction
        let displaced = displace(position)
        if map[displaced] != .slippery || boardState[displaced].isSquare {
            return .fail
        }
        if let slippedState = boardState[safe: displace(displaced)],
           let slippedMapTile = map[safe: displace(displaced)] {
            switch (slippedMapTile, slippedState) {
            case (.void, _):
                return .death
            case (.wall, _), (_, .square), (_, .deadBody):
                return .fail
            default:
                return .success
            }
        } else {
            return .fail
        }
    }
    
    func isEdge(position: Position) -> [Direction] {
        var directions = [Direction]()
        if case .void = map[position.above()] {
            directions.append(.up)
        }
        if case .void = map[position.below()] {
            directions.append(.down)
        }
        if case .void = map[position.left()] {
            directions.append(.left)
        }
        if case .void = map[position.right()] {
            directions.append(.right)
        }
        return directions
    }

    private func spawnNewSquare(color: Color) {
        boardState[spawnpoints[color]!] = .square(color)
    }
    
    enum SlipResult {
        case success
        case fail
        case death
    }
}
