public class TypeErasedState: HashableRepresentative, CustomDebugStringConvertible {
    var representee: AnyObject

    public var name: String

    let state: Any

    init<StateType>(from dslState: State<StateType>) {
        name = dslState.name
        state = Any(dslState)
        representee = dslState
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
