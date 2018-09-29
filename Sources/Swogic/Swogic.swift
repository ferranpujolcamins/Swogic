// TODO: ADD CI MARKUP TAGS TO README.md

prefix operator =>
prefix operator *
infix operator --- : MultiplicationPrecedence
infix operator ---> : MultiplicationPrecedence
infix operator ---| : MultiplicationPrecedence
infix operator |---> : MultiplicationPrecedence


//public func ---> <I,U,O> (_ lhs: @escaping (I)->(U), _ rhs: @escaping (U)->(O)) -> StepChain<I, O> {
//    return Step(lhs) ---> Step(rhs)
//}
//
//public func --- <I,U,O> (_ lhs: @escaping (I)->(U), _ rhs: @escaping (U)->(O)) -> StepChain<I, O> {
//    return Step(lhs) ---> Step(rhs)
//}






// v2: tags?
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
