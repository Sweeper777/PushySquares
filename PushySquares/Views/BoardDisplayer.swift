import PushySquaresModel

protocol BoardDisplayer {
    func animateMoveResult(_ moveResult: MoveResult)
    var delegate: BoardViewDelegate? { get set }
    var board: BoardProvider! { get set }
}

extension BoardView : BoardDisplayer {
}