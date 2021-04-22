import UIKit
import PushySquaresModel

protocol GameControllerStrategy {
    func didRestartGame()
    func didEndAnimatingMoveResult(_ moveResult: MoveResult)
    func makeMenuButtons() -> [UIView]?
    func willMove(_ direction: Direction)
}
