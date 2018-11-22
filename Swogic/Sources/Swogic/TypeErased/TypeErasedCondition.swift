public class TypeErasedCondition: HashableRepresentative, CustomDebugStringConvertible {
    var representee: AnyObject

    private let closure: (Any) -> Any

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
    
    public func evaluate(_ value: Any) -> Bool {
        return closure(value) as! Bool
    }
}

public class TypeErasedMatchCondition: HashableRepresentative, CustomDebugStringConvertible {
    var representee: AnyObject

    private let closure: (Any) -> Any

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

    public func evaluate(_ value: Any) -> Bool {

        return (closure(()) as! EquatableToAny).isEqual(to: value)
    }
}

public class TypeErasedMatchAfterProjectionCondition: HashableRepresentative, CustomDebugStringConvertible {
    var representee: AnyObject

    private let closure: (Any) -> Any
    private let projection: (Any) -> Any

    init<I>(from dslCondition: MatchAfterProjectionCondition<I>) {
        closure = eraseType(dslCondition.pattern)
        self.projection = eraseType(I.projection)
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

    public func evaluate(_ value: Any) -> Bool {

        return (closure(()) as! EquatableToAny).isEqual(to: projection(value))
    }
}
