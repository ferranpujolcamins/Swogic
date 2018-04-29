import SwiftGraph

infix operator ---| : MultiplicationPrecedence
infix operator |---> : MultiplicationPrecedence

protocol AnyAction {
}

// TODO: result type should be equatable, add protocol for result
class Action<ResultType>: AnyAction {

    // MARK: - Public interface:

    init(_ action: @escaping () -> ResultType) {
        self.action = action
    }

    // MARK: - Implementation

    let action: () -> ResultType

    // TODO: postfix and infix version of operators that emit a custom warning of whitespace with operators
    static func ---| (action: Action<ResultType> , result: ResultType) -> ActionPreChain {
        return ActionPreChain(action: action, result: result)
    }
}

class EndOperation: Action<Void> {

}

struct ActionPreChain {

    let action: AnyAction
    let result: Any
    static func |---> <NextActionResultType> (preChain: ActionPreChain , nextAction: Action<NextActionResultType>) -> ActionChain<NextActionResultType> {
        return ActionChain<NextActionResultType>(preChain: preChain, nextAction: nextAction)
    }
}

protocol AnyActionChain: AnyAction {

}

struct ActionChain<LastActionResultType>: AnyActionChain {

    let preChain: ActionPreChain;
    let nextAction: Action<LastActionResultType>;

    static func ---| (ac: ActionChain<LastActionResultType>, result: LastActionResultType) -> ActionPreChain {
        return ActionPreChain(action: ac, result: result)
    }
}

class Flow {
    init(_ actionChains: AnyActionChain...) {
        for actionChain in actionChains {
            
        }
    }
}


// v2
/*
let flow = Flow(
    login ---|.ok |---> request ---|.ok |---> endAction,
    login ---|.ok |---> request ---|.401|---> refresh,
    login ---|.401|---> refresh,

    refresh: refresh ---|.ok  |---> retry,
             refresh ---|.fail|---> reportError
);
*/
