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
}

public final class MatchCondition<I: EquatableToAny>: Nameable, CustomDebugStringConvertible {
    public var name: String = ""

    public typealias Literal = () -> I

    public let pattern: Literal

    public init(_ literal: @escaping Literal) {
        pattern = literal
    }
}

public final class MatchAfterProjectionCondition<I: EquatableAfterProjection>: Nameable, CustomDebugStringConvertible {
    public var name: String = ""

    public typealias Literal = () -> I.Projected

    public let pattern: Literal

    public init(_ literal: @escaping Literal) {
        pattern = literal
    }
}

extension String {
    public static func ~ <I> (_ name: String, _ literal: @escaping Condition<I>.Literal) -> Condition<I> {
        let condition = Condition(literal)
        condition.name = name
        return condition
    }

    public static func ~ <I> (_ name: String, _ literal: @escaping MatchCondition<I>.Literal) -> MatchCondition<I> {
        let condition = MatchCondition(literal)
        condition.name = name
        return condition
    }

    public static func ~ <I> (_ name: String, _ literal: @escaping MatchAfterProjectionCondition<I>.Literal) -> MatchAfterProjectionCondition<I> {
        let condition = MatchAfterProjectionCondition<I>(literal)
        condition.name = name
        return condition
    }
}
