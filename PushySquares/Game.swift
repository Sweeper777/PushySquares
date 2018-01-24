

public class Game {
    static let playerCountToTurnsUntilNewSquare = [
        2: 2,
        3: 4,
        4: 4
    ]
    
    public var board: Array2D<Tile>
    public var spawnpoints: [Color: Position]
    public let slipperyPositions: [Position]
    public var players = [Player]()
    public var currentPlayer: Player {
        return players[currentPlayerIndex]
    }
    
    private var currentPlayerIndex = 0
    
    public weak var delegate: GameDelegate?
    
    public init(map: Map, playerCount: Int, lives: Int = 5) {
        self.board = map.board
        self.spawnpoints = map.spawnpoints
        self.slipperyPositions = map.slipperyPositions
        switch playerCount {
        case 4:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .color4))
            spawnNewSquare(color: .color4)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], slippedPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color4)
            fallthrough
        case 3:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .color2))
            spawnNewSquare(color: .color2)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], slippedPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color2)
            fallthrough
        case 2:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .color1))
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .color3))
            spawnNewSquare(color: .color1)
            spawnNewSquare(color: .color3)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], slippedPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color1)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], slippedPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color3)
        default:
            fatalError()
        }
        
        players.sort { $0.color.rawValue < $1.color.rawValue }
        
        if playerCount < 4 {
            spawnpoints[.color4] = nil
        }
        
        if playerCount < 3 {
            spawnpoints[.color2] = nil
        }
        
        currentPlayer.turnsUntilNewSquare -= 1
    }
    
    public init(game: Game) {
        self.board = game.board
        self.spawnpoints = game.spawnpoints
        self.players = game.players.map { $0.createCopy() }
        self.currentPlayerIndex = game.currentPlayerIndex
    }
    
    public func moveUp() {
        move(sorter: { $0.y < $1.y }, direction: .up)
    }
    
    public func moveDown() {
        move(sorter: { $0.y > $1.y }, direction: .down)
    }
    
    public func moveLeft() {
        move(sorter: { $0.x < $1.x }, direction: .left)
    }
    
    public func moveRight() {
        move(sorter: { $0.x > $1.x }, direction: .right)
    }
    
    public func killPlayer(_ color: Color) {
        guard let index = players.index(where: { $0.color == color && $0.lives > 0 }) else { return }
        let player = players[index]
        player.lives = 0
        var greyedOutPositions = [Position]()
        for position in board.indicesOf(color: color) {
            board[position] = .square(.grey)
            greyedOutPositions.append(position)
        }
        var newSquareColor: Color?
        if currentPlayer.color == color {
            newSquareColor = nextTurn()
        }
        
        delegate?.playerDidMakeMove(direction: nil, originalPositions: [], slippedPositions: [], destroyedSquarePositions: [], greyedOutPositions: greyedOutPositions, newSquareColor: newSquareColor)
    }
    
    private func move(sorter: (Position, Position) -> Bool, direction: Direction) {
        let displace = direction.displacementFunction
        let allSquaresPositions = board.indicesOf(color: currentPlayer.color)
        
        if allSquaresPositions.isEmpty {
            let newSquareColor = nextTurn()
            delegate?.playerDidMakeMove(direction: direction, originalPositions: [], slippedPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: newSquareColor)
            return
        }
        
        var movingSquaresPositions = [Position]()
        var beingDestroyedSquaresPositions = [Position]()
        for position in allSquaresPositions {
            var pushedPositions = [position]
            loop: while true {
                switch board[displace(pushedPositions.last!)] {
                case .empty:
                    break loop
                case .wall:
                    pushedPositions = []
                    break loop
                case .void:
                    beingDestroyedSquaresPositions.append(pushedPositions.last!)
                    break loop
                case .square:
                    pushedPositions.append(displace(pushedPositions.last!))
                }
            }
            movingSquaresPositions.append(contentsOf: pushedPositions)
        }
        let sortedPositions = Set(movingSquaresPositions).sorted(by: sorter)
        beingDestroyedSquaresPositions = Array(Set(beingDestroyedSquaresPositions))
        
        let greyedOutSquaresPositions = handleDeaths(destroyedSquarePositions: beingDestroyedSquaresPositions)
        
        for position in sortedPositions {
            let tile = board[position]
            board[position] = .empty
            if !beingDestroyedSquaresPositions.contains(position) {
                board[displace(position)] = tile
            }
        }
        let newSquareColor = nextTurn()
        delegate?.playerDidMakeMove(direction: direction,
                                    originalPositions: sortedPositions,
                                    slippedPositions: slippedPositions,
                                    destroyedSquarePositions: beingDestroyedSquaresPositions,
                                    greyedOutPositions: greyedOutSquaresPositions,
                                    newSquareColor: newSquareColor)
    }
    
    private func nextTurn() -> Color? {
        var retVal: Color?
        
        if (!players.contains { $0.lives > 0 }) {
            return .grey
        }
        
        repeat {
            currentPlayerIndex = currentPlayerIndex == players.endIndex - 1 ? 0 : currentPlayerIndex + 1
        } while currentPlayer.lives == 0
        currentPlayer.turnsUntilNewSquare -= 1
        if currentPlayer.turnsUntilNewSquare == 0 {
            if case .empty = board[spawnpoints[currentPlayer.color]!] {
                spawnNewSquare(color: currentPlayer.color)
                retVal = currentPlayer.color
            }
            currentPlayer.turnsUntilNewSquare = Game.playerCountToTurnsUntilNewSquare[players.count]! + 1
        }
        return retVal
    }
    
    private func handleDeaths(destroyedSquarePositions: [Position]) -> [Position] {
        var retVal = [Position]()
        for player in players {
            let destroyedSquares = destroyedSquarePositions.filter {
                if case .square(player.color) = board[$0] {
                    return true
                } else {
                    return false
                }
            }
            player.lives -= destroyedSquares.count
            if player.lives == 0 {
                for pos in board.indicesOf(color: player.color) {
                    retVal.append(pos)
                    board[pos] = .square(.grey)
                }
            }
        }
        return retVal
    }
    
    private func spawnNewSquare(color: Color) {
        board[spawnpoints[color]!] = .square(color)
    }
    
    enum SlipResult {
        case success
        case fail
        case death
    }
}
