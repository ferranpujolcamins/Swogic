public enum PlaceHolderCondition: Equatable {
    public typealias Literal = () -> ()

    case new
}

public final class Condition<I>: Nameable, CustomDebugStringConvertible {
    public var name: String = ""

    public typealias Literal = (I) -> Bool

    public let condition: Literal

    public init(_ literal: @escaping Literal) {
        condition = literal
    }

    public func evaluate(_ value: I) -> Bool {
        return condition(value)
    }
}

public final class MatchCondition<I: Equatable>: Nameable, CustomDebugStringConvertible {
    public var name: String = ""

    public typealias Literal = () -> I

    public let pattern: Literal

    public init(_ literal: @escaping Literal) {
        pattern = literal
    }

    public func evaluate(_ value: I) -> Bool {
        if case pattern() = value {
            return true
        }
        return false
    }
}

extension String {
    public static func ~ <I> (_ literal: @escaping Condition<I>.Literal, _ name: String) -> Condition<I> {
        let condition = Condition(literal)
        condition.name = name
        return condition
    }

    public static func ~ <I> (_ literal: @escaping MatchCondition<I>.Literal, _ name: String) -> MatchCondition<I> {
        let condition = MatchCondition(literal)
        condition.name = name
        return condition
    }
}
