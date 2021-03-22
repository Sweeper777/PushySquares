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

    func runAnimation(completion: (() -> Void)?) {
        let indices = phases.indices
        for (i, next) in zip(indices, indices.dropFirst()) {
            phases[i].onEnd = { [weak self] in
                guard let `self` = self else { return }
                self.completionHandlers[i]?()
                self.phases[next].start(animations: self.groups[next])
            }
        }
        if let first = phases.first, let last = phases.last {
            last.onEnd = completion
            first.start(animations: groups.first!)
        } else {
            completion?()
        }
    }

}