public class TypeErasedStep: DomainStep, HashableRepresentative, CustomDebugStringConvertible {
    var representee: AnyObject

    public var name: String

    let closure: (Any) -> Any

    init<I,O>(from dslStep: Step<I, O>) {
        name = dslStep.name
        closure = eraseType(dslStep.closure)
        representee = dslStep
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


protocol HashableRepresentative: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool

    var representee: AnyObject { get };
}

extension HashableRepresentative {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.representee === rhs.representee
    }

    public var hashValue: Int {
        get {
            return ObjectIdentifier(self.representee).hashValue
        }
    }
}
