

public class Game {
    public var board: Array2D<Tile>
    public var spawnpoints: [Color: Position]
    public var players = [Player]()
    public var currentPlayer: Player {
        return players[currentPlayerIndex]
    }
    
    private var currentPlayerIndex = 0
    
    public weak var delegate: GameDelegate?
    
    public init(map: Map, playerCount: Int, lives: Int = 5) {
        self.board = map.board
        self.spawnpoints = map.spawnpoints
        switch playerCount {
        case 4:
            players.append(Player(turnsUntilNewSquare: playerCount, lives: lives, color: .color4))
            spawnNewSquare(color: .color4)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color4)
            fallthrough
        case 3:
            players.append(Player(turnsUntilNewSquare: playerCount, lives: lives, color: .color2))
            spawnNewSquare(color: .color2)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color2)
            fallthrough
        case 2:
            players.append(Player(turnsUntilNewSquare: playerCount, lives: lives, color: .color1))
            players.append(Player(turnsUntilNewSquare: playerCount, lives: lives, color: .color3))
            spawnNewSquare(color: .color1)
            spawnNewSquare(color: .color3)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color1)
            delegate?.playerDidMakeMove(direction: nil, originalPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: .color3)
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
    
    public func moveUp() {
        move(displacement: { $0.above() }, sorter: { $0.y < $1.y }, direction: .up)
    }
    
    public func moveDown() {
        move(displacement: { $0.below() }, sorter: { $0.y > $1.y }, direction: .down)
    }
    
    public func moveLeft() {
        move(displacement: { $0.left() }, sorter: { $0.x < $1.x }, direction: .left)
    }
    
    public func moveRight() {
        move(displacement: { $0.right() }, sorter: { $0.x > $1.x }, direction: .right)
    }
    
    private func move(displacement displace: (Position) -> Position, sorter: (Position, Position) -> Bool, direction: Direction) {
        let allSquaresPositions = board.indicesOf(color: currentPlayer.color)
        
        if allSquaresPositions.isEmpty {
            let newSquareColor = nextTurn()
            delegate?.playerDidMakeMove(direction: direction, originalPositions: [], destroyedSquarePositions: [], greyedOutPositions: [], newSquareColor: newSquareColor)
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
        
        let newSquareColor = nextTurn()
        let greyedOutSquaresPositions = handleDeaths(destroyedSquarePositions: beingDestroyedSquaresPositions)
        
        for position in sortedPositions {
            let tile = board[position]
            board[position] = .empty
            if !beingDestroyedSquaresPositions.contains(position) {
                board[displace(position)] = tile
            }
        }
        delegate?.playerDidMakeMove(direction: direction, originalPositions: sortedPositions, destroyedSquarePositions: beingDestroyedSquaresPositions, greyedOutPositions: greyedOutSquaresPositions, newSquareColor: newSquareColor)
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
            currentPlayer.turnsUntilNewSquare = players.count + 1
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
}
