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

public class Condition<I>: AnyChainElement {
    public typealias Literal = (I) -> Bool

    public let condition: Literal

    public init(_ literal: @escaping Literal) {
        condition = literal
    }

    public func evaluate(_ value: I) -> Bool {
        return condition(value)
    }
}

public class MatchCondition<I: Equatable>: AnyChainElement {
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
