//
//  Conditions.swift
//  Swogic
//
//  Created by Ferran Pujol Camins on 04/05/2018.
//

public enum PlaceHolderCondition: AnyChainElement, Equatable {
    public typealias Literal = () -> ()

    case new
}

public class Condition<I>: DomainCondition, AnyChainElement, CustomDebugStringConvertible {
    public var debugDescription: String {
        get {
            return name
        }
    }

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

public class MatchCondition<I: Equatable>: DomainMatchCondition, AnyChainElement, CustomDebugStringConvertible {
    public var debugDescription: String {
        get {
            return name
        }
    }
    
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
    static func ~ <I> (_ literal: @escaping Condition<I>.Literal, _ name: String) -> Condition<I> {
        let condition = Condition(literal)
        condition.name = name
        return condition
    }

    static func ~ <I> (_ literal: @escaping MatchCondition<I>.Literal, _ name: String) -> MatchCondition<I> {
        let condition = MatchCondition(literal)
        condition.name = name
        return condition
    }
}
