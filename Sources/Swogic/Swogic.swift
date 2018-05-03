// TODO: ADD CI MARKUP TAGS TO README.md

prefix operator *
infix operator --- : MultiplicationPrecedence
infix operator ---> : MultiplicationPrecedence

public protocol AnyStep {}

struct Step<I, O>: AnyStep {
    private var specific: Bool = false;

    static prefix func * (_ step: Step<I, O>) -> Step<I, O> {
        var newStep = step;
        newStep.specific = true;
        return newStep
    }

    static func ---> <U> (_ lhs: Step<I, U>, _ rhs: Step<U, O>) -> StepChain<I, O> {
        return StepChain(step: lhs) ---> rhs
    }

    static func --- (_ step: Step<I, O>, _ condition: @escaping Condition<O>.Literal) -> StepChain<I, O> {
        return StepChain(step: step) ---> Condition<O>(condition)
    }
}

extension Step where O: Equatable {
    static func --- (_ step: Step<I, O>, _ condition: @escaping MatchCondition<O>.Literal) -> StepChain<I, O> {
        return StepChain(step: step) ---> MatchCondition<O>(condition)
    }
}

internal struct Condition<I>: AnyStep {
    typealias Literal = (I) -> Bool

    let condition: Literal

    init(_ literal: @escaping Literal) {
        condition = literal
    }

    public func evaluate(_ value: I) -> Bool {
        return condition(value)
    }
}

internal struct MatchCondition<I: Equatable>: AnyStep {
    typealias Literal = () -> I

    let pattern: Literal

    init(_ literal: @escaping Literal) {
        pattern = literal
    }

    public func evaluate(_ value: I) -> Bool {
        if case pattern() = value {
            return true
        }
        return false
    }
}

// DSL motivated types


// v2
/*
let flow = Flow(
    login ---| .ok   |---> request ---|.ok |---> endAction,
    login ---| .ok   |---> request ---|.c401|---> refresh,
    login ---| .c401 |---> refresh,
    login ---| .c500 |---> action1 ---> action2

    refresh: refresh ---|.ok  |---> retry,
             refresh ---|.fail|---> reportError
);
*/
