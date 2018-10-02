public protocol Step {}

public class ExecutionStep<I, O>: Step, CustomDebugStringConvertible {

    let closure: (I) -> O
    public var name: String = ""

    public var debugDescription: String {
        get {
            return name
        }
    }

    public init(_ closure: @escaping (I) -> O) {
        self.closure = closure
    }

    public func copy() -> ExecutionStep<I, O> {
        return ExecutionStep<I, O>(closure)
    }

    public static prefix func => (_ step: ExecutionStep<I, O>) -> ExecutionStep<I, O> {
        return step
    }

    public static prefix func * (_ step: ExecutionStep<I, O>) -> ExecutionStep<I, O> {
        return step.copy()
    }

    public static func ---> <U> (_ lhs: ExecutionStep<I, U>, _ rhs: ExecutionStep<U, O>) -> ValidStepChain<I, O> {
        return ValidStepChain(step: lhs) ---> rhs
    }

    public static func --- (_ step: ExecutionStep<I, O>, _ condition: @escaping Condition<O>.Literal) -> ValidStepChain<I, O> {
        return ValidStepChain(step: step) ---> Condition<O>(condition)
    }

    public static func --- (_ step: ExecutionStep<I, O>, _ placeholder: @escaping PlaceHolderCondition<O>.Literal) -> ValidStepChain<I, O> {
        return ValidStepChain(step: step) ---> PlaceHolderCondition<O>.new
    }
}

extension ExecutionStep where O: Equatable {
    public static func --- (_ step: ExecutionStep<I, O>, _ condition: @escaping MatchCondition<O>.Literal) -> ValidStepChain<I, O> {
        return ValidStepChain(step: step) ---> MatchCondition<O>(condition)
    }
}
