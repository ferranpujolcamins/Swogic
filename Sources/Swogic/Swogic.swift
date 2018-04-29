infix operator ---| : MultiplicationPrecedence
infix operator |---> : MultiplicationPrecedence

protocol AnyAction {
}

// TODO: result type should be equatable
class Action<ResultType>: AnyAction {

    // TODO: postfix and infix version of operators that emit a custom warning of whitespace with operators
    static func ---| (action: Action<ResultType> , result: ResultType) -> ActionPreChain {
        return ActionPreChain()
    }
}

class EndOperation: Action<Void> {

}

struct ActionPreChain {

    static func |---> <NextActionResultType> (preChain: ActionPreChain , nextAction: Action<NextActionResultType>) -> ActionChain<NextActionResultType> {
        return ActionChain<NextActionResultType>()
    }
}

protocol AnyActionChain {

}

struct ActionChain<LastActionResultType>: AnyActionChain {
//    let action: AnyAction;
//    let result: Any;
//    let nextAction: Action<LastActionResultType>;

    static func ---| (op: ActionChain<LastActionResultType>, result: LastActionResultType) -> ActionPreChain {
        return ActionPreChain()
    }
}

class Flow {
    init(_ actionChains: AnyActionChain...) {

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
