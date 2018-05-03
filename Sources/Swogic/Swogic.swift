import SwiftGraph

// TODO: ADD CI MARKUP TAGS TO README.md

prefix operator *
infix operator ---| : MultiplicationPrecedence
infix operator |---> : MultiplicationPrecedence
infix operator ------> : MultiplicationPrecedence

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


struct Action<I: Swogicable, O: Swogicable> {


    static prefix func * (_ action: Action<I, O>) -> Step<I, O> {
        return Step(action, specific: true)
    }

    static func ------> <U> (_ lhs: Action<I, U>, _ rhs: Action<U, O>) -> StepChain<I, O> {
        return *lhs ------> *rhs
    }

    static func ------> <U> (_ lhs: Action<I, U>, _ rhs: Step<U, O>) -> StepChain<I, O> {
        return *lhs ------> rhs
    }

    static func ------> <U> (_ lhs: Step<I, U>, _ rhs: Action<U, O>) -> StepChain<I, O> {
        return lhs ------> *rhs
    }

    static func ------> <U> (_ lhs: StepChain<I, U>, _ rhs: Action<U, O>) -> StepChain<I, O> {
        return lhs ------> *rhs
    }
}

protocol AnyStep {}

struct Step<I: Swogicable, O: Swogicable>: AnyStep {

    let action: Action<I, O>

    init(_ action: Action<I, O>, specific: Bool = false) {
        self.action = action
    }

    static func ------> <U> (_ lhs: Step<I, U>, _ rhs: Step<U, O>) -> StepChain<I, O> {
        return StepChain(step: lhs) ------> rhs
    }
}

protocol AnyStepChain {
}

extension AnyStepChain {
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

    static func ------> <U> (_ stepChain: StepChain<I, U>, _ newStep: Step<U, O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + newStep)
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
