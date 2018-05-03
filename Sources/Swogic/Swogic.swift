import SwiftGraph

// TODO: ADD CI MARKUP TAGS TO README.md

prefix operator *
infix operator --- : MultiplicationPrecedence
infix operator ---> : MultiplicationPrecedence

protocol Swogicable {}

// unit type
enum Void: Swogicable {

    init() {
        self = .void
    }

    case void

    static func ==(lhs: Void, rhs: Void) -> Bool {
        return true
    }
}

enum BottomType: Swogicable {

    static func ==(lhs: BottomType, rhs: BottomType) -> Bool {
        return false
    }
}


protocol AnyStep {}

struct Step<I: Swogicable, O: Swogicable>: AnyStep {
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

fileprivate indirect enum StepChainDataStructure {
    case step(AnyStep)
    case stepChain(StepChainDataStructure, AnyStep)

    public init(_ step: AnyStep) {
        self = .step(step)
    }

    public static func + (_ chain: StepChainDataStructure, _ newStep: AnyStep) -> StepChainDataStructure {
        switch chain {
        case .step(let step):
            return .stepChain(.step(step), newStep)

        case .stepChain (let innerChain, let step):
            return .stepChain(innerChain + step, newStep)
        }
    }
}

struct StepChain<I: Swogicable, O: Swogicable> {
    private var stepChainData: StepChainDataStructure

    public init(step: AnyStep) {
        self.stepChainData = StepChainDataStructure(step)
    }

    private init(stepChainData: StepChainDataStructure) {
        self.stepChainData = stepChainData
    }

    static func ---> <U> (_ stepChain: StepChain<I, U>, _ newStep: Step<U, O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + newStep)
    }

    static func ---> (_ stepChain: StepChain<I, O>, _ condition: Condition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}

extension StepChain where O: Equatable {
    static func ---> (_ stepChain: StepChain<I, O>, _ condition: MatchCondition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
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
