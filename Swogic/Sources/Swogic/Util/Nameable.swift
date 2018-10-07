protocol Nameable: CustomDebugStringConvertible {
    var name: String { get set }
}

extension Nameable {

    public var debugDescription: String {
        get {
            return name
        }
    }
}
