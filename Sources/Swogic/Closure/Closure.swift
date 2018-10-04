//infix operator *? : MultiplicationPrecedence
//
//public struct ClosureRuntimeType {
//    public let inputType: ObjectIdentifier
//    public let outputType: ObjectIdentifier
//
//    public init(_ inputType: ObjectIdentifier, _ outputType: ObjectIdentifier) {
//        self.inputType = inputType
//        self.outputType = outputType
//    }
//}
//
//public protocol AbstractClosure {
//    // This can crash if closures dont compose
//    func evaluate(_ a: Any) -> Any
//}

public func eraseType<I>(_ c: @escaping (I) -> Any) -> (Any) -> Any {
    return { a in c(a as! I) }
}

//public struct Closure<I>: AbstractClosure {
//    let closure: (I) -> Any
//
//    public init(_ c: @escaping (I) -> Any) {
//        closure = c
//    }
//
//    public func evaluate(_ a: Any) -> Any {
//        return closure(a as! I)
//    }
//}
//
//public struct Closure<I>: AbstractClosure {
//    let closure: (I) -> Any
//
//    public init(_ c: @escaping (I) -> Any) {
//        closure = c
//    }
//
//    public func evaluate(_ a: Any) -> Any? {
//        if let v = a as? I {
//            return closure(v)
//        }
//        return nil
//    }
//}

//public struct Closure {
//    let closure: Any
//    let closureType: ObjectIdentifier
//    let runtimeType: ClosureRuntimeType
//
//    public init<I, O>(_ closure: @escaping (I) -> O) {
//        self.closure = closure
//        closureType = ObjectIdentifier(type(of: closure))
//        runtimeType = ClosureRuntimeType(ObjectIdentifier(I.self), ObjectIdentifier(O.self))
//    }
//
//    public static func *? (_ lhs: Closure, _ rhs: Closure) -> Bool {
//        return lhs.runtimeType.inputType == rhs.runtimeType.outputType
//    }
//}
