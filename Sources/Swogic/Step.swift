public protocol AnyStep {}

public class InitialStep<I,O>: Step<I,O> {
    init(_ step: Step<I,O>) {
        super.init(step.closure)
    }
}

public class Step<I, O>: AnyStep {

    let closure: (I) -> O

    public init(_ closure: @escaping (I) -> O) {
        self.closure = closure
    }

    public func copy() -> Step<I, O> {
        return Step<I, O>(closure)
    }

    public static prefix func => (_ step: Step<I, O>) -> InitialStep<I, O> {
        return InitialStep(step)
    }

    public static prefix func * (_ step: Step<I, O>) -> Step<I, O> {
        return step.copy()
    }

    public static func ---> <U> (_ lhs: Step<I, U>, _ rhs: Step<U, O>) -> StepChain<I, O> {
        return StepChain(step: lhs) ---> rhs
    }

    public static func --- (_ step: Step<I, O>, _ condition: @escaping Condition<O>.Literal) -> StepChain<I, O> {
        return StepChain(step: step) ---> Condition<O>(condition)
    }

    public static func --- (_ step: Step<I, O>, _ placeholder: @escaping PlaceHolderCondition<O>.Literal) -> StepChain<I, O> {
        return StepChain(step: step) ---> PlaceHolderCondition<O>.new
    }
}

extension Step where O: Equatable {
    public static func --- (_ step: Step<I, O>, _ condition: @escaping MatchCondition<O>.Literal) -> StepChain<I, O> {
        return StepChain(step: step) ---> MatchCondition<O>(condition)
    }
}
