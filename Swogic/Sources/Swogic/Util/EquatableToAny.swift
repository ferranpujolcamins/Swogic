public protocol EquatableToAny {
    func isEqual(to other: Any) -> Bool
}

extension Equatable {
    public func isEqual(to other: Any) -> Bool {
        if let other = other as? Self {
            return other == self
        }
        return false
    }
}

// Todo sourcery to autoconformance of all equatable Foundation types?
extension Int: EquatableToAny {}
extension Double: EquatableToAny {}
extension String: EquatableToAny {}
