public class Player {
    public var turnsUntilNewSquare: Int
    public var lives: Int {
        didSet {
            if lives < 0 {
                lives = 0
            }
        }
    }
    public let color: Color
    
    init(turnsUntilNewSquare: Int, lives: Int, color: Color) {
        self.turnsUntilNewSquare = turnsUntilNewSquare
        self.lives = lives
        self.color = color
    }
}
