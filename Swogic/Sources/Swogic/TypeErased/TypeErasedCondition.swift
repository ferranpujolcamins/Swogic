public class TypeErasedCondition: HashableRepresentative, CustomDebugStringConvertible {
    public var name: String = ""

    var representee: AnyObject

    let closure: (Any) -> Any

    init<I>(from dslCondition: Condition<I>) {
        closure = eraseType(dslCondition.condition)
        representee = dslCondition
    }

    public var debugDescription: String {
        get {
            if let representee = representee as? CustomDebugStringConvertible {
                return representee.debugDescription
            } else {
                return ""
            }
        }
    }
}

public class TypeErasedMatchCondition: HashableRepresentative, CustomDebugStringConvertible {
    public var name: String = ""

    var representee: AnyObject

    let closure: (Any) -> Any

    init<I>(from dslCondition: MatchCondition<I>) {
        closure = eraseType(dslCondition.pattern)
        representee = dslCondition
    }

    public var debugDescription: String {
        get {
            if let representee = representee as? CustomDebugStringConvertible {
                return representee.debugDescription
            } else {
                return ""
            }
        }
    }
}
