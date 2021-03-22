import PushySquaresModel

class AnimationManager<Phase: AnimationPhase> {
    typealias Animatable = Phase.AnimatedObject
    typealias AnimationGroup = [AnimationType: [Animatable]]
    private var groups = [AnimationGroup]()
    private var completionHandlers = [(() -> Void)?]()
    private var phases = [Phase]()

    func addPhase(group: AnimationGroup, duration: TimeInterval, completion: (() -> Void)?) {
        groups.append(group)
        completionHandlers.append(completion)
        phases.append(Phase(duration: duration))
    }

}