import UIKit

class GameViewController: UIViewController, GameDelegate {

    @IBOutlet var boardView: GameBoardView!
    let game = Game(map: .standard, playerCount: 4)
    
    var swipeUpGR: UISwipeGestureRecognizer!
    var swipeDownGR: UISwipeGestureRecognizer!
    var swipeLeftGR: UISwipeGestureRecognizer!
    var swipeRightGR: UISwipeGestureRecognizer!
    
    var allGR: [UIGestureRecognizer] {
        return [swipeUpGR, swipeDownGR, swipeRightGR, swipeLeftGR]
    }
    
    override func viewDidLoad() {
        boardView.game = self.game
        
        game.delegate = self
        
        swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeDownGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeRightGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeUpGR.direction = .up
        swipeDownGR.direction = .down
        swipeLeftGR.direction = .left
        swipeRightGR.direction = .right
        
        allGR.forEach { self.view.addGestureRecognizer($0) }
        
    }
    
    func swipedUp() {
        game.moveUp()
    }
    
    func swipedDown() {
        game.moveDown()
    }
    
    func swipedLeft() {
        game.moveLeft()
    }
    
    func swipedRight() {
        game.moveRight()
    }
    
    func playerDidMakeMove(direction: Direction?, originalPositions: [Position], destroyedSquarePositions: [Position], greyedOutPositions: [Position], newSquareColor: Color?) {
        var moveAnim = Animate()
        
        for position in originalPositions {
            let squareView = boardView.viewWithTag(position.hashValue) as! SquareView
            let squareViewMove: Animate
            switch direction! {
            case .down:
                squareViewMove = squareView.moveDown
            case .up:
                squareViewMove = squareView.moveUp
            case .left:
                squareViewMove = squareView.moveLeft
            case .right:
                squareViewMove = squareView.moveRight
            }
            moveAnim = moveAnim.and(animation: squareViewMove)
        }
        
        var destroyedAnim = Animate()
        moveAnim.perform()
    }
}

