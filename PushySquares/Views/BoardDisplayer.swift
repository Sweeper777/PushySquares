import PushySquaresModel

protocol BoardDisplayer : class {
    func animateMoveResult(_ moveResult: MoveResult)
    var delegate: BoardViewDelegate? { get set }
    var board: BoardProvider! { get set }
}

extension BoardView : BoardDisplayer {
}