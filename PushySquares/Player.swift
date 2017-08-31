public class Player {
    public var turnsUntilNewSquare: Int
    public var lives: Int
    public let color: Color
    
    init(turnsUntilNewSquare: Int, lives: Int, color: Color) {
        self.turnsUntilNewSquare = turnsUntilNewSquare
        self.lives = lives
        self.color = color
    }
}
