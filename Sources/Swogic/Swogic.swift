// TODO: ADD CI MARKUP TAGS TO README.md

prefix operator *
infix operator --- : MultiplicationPrecedence
infix operator ---> : MultiplicationPrecedence

public protocol AnyStep {}

public struct Step<I, O>: AnyStep {

    public init() {

    }

    private var specific: Bool = false;

    public static prefix func * (_ step: Step<I, O>) -> Step<I, O> {
        var newStep = step;
        newStep.specific = true;
        return newStep
    }

    public static func ---> <U> (_ lhs: Step<I, U>, _ rhs: Step<U, O>) -> StepChain<I, O> {
        return StepChain(step: lhs) ---> rhs
    }

    public static func --- (_ step: Step<I, O>, _ condition: @escaping Condition<O>.Literal) -> StepChain<I, O> {
        return StepChain(step: step) ---> Condition<O>(condition)
    }
}

extension Step where O: Equatable {
    public static func --- (_ step: Step<I, O>, _ condition: @escaping MatchCondition<O>.Literal) -> StepChain<I, O> {
        return StepChain(step: step) ---> MatchCondition<O>(condition)
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
