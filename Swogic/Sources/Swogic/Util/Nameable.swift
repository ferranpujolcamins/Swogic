public protocol Nameable: Copyable, CustomDebugStringConvertible {
    var name: String { get set }
}

extension Nameable {

    public var debugDescription: String {
        get {
            return name
        }
    }
}


extension String {
    public static func ~ <N: Nameable> (_ name: String, _ nameable: N) -> N {
        var copy = nameable.copy()
        copy.name = name
        return copy
    }
}
