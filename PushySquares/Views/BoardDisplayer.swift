import PushySquaresModel

protocol BoardDisplayer : class {
    func animateMoveResult(_ moveResult: MoveResult)
    var delegate: BoardDisplayerDelegate? { get set }
    var board: BoardProvider! { get set }
}

protocol BoardDisplayerDelegate: class {
    func boardDidEndAnimatingMoveResult(_ boardDisplayer: BoardDisplayer, moveResult: MoveResult)
}

extension BoardView : BoardDisplayer {
}