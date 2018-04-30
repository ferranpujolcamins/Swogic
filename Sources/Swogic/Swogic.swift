import SwiftGraph

infix operator ---| : MultiplicationPrecedence
infix operator |---> : MultiplicationPrecedence

protocol AnyAction {
}

protocol Result: Equatable {

}

enum VoidResult: Result {

    init() {
        self = .void;
    }

    case void

    static func ==(lhs: VoidResult, rhs: VoidResult) -> Bool {
        return true
    }
}

class Action<ResultType: Result>: AnyAction {

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

extension Action where ResultType == VoidResult {

    convenience init(_ action: @escaping () -> Void) {
        self.init { () -> VoidResult in
            action()
            return .void
        }
    }
}

typealias VoidAction = Action<VoidResult>

struct ActionPreChain {

    let action: AnyAction
    let result: Any
    static func |---> <NextActionResultType> (preChain: ActionPreChain , nextAction: Action<NextActionResultType>) -> ActionChain<NextActionResultType> {
        return ActionChain<NextActionResultType>(preChain: preChain, nextAction: nextAction)
    }
}

protocol AnyActionChain: AnyAction {

}

struct ActionChain<LastActionResultType: Result>: AnyActionChain {

    let preChain: ActionPreChain;
    let nextAction: Action<LastActionResultType>;

    static func ---| (ac: ActionChain<LastActionResultType>, result: LastActionResultType) -> ActionPreChain {
        return ActionPreChain(action: ac, result: result)
    }
}

class Flow {
    init(_ actionChains: AnyActionChain...) {
        for actionChain in actionChains {
            // TODO: ADD CI MARKUP TAGS TO README.md
        }
    }
}


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
