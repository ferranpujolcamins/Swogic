//
//  Conditions.swift
//  Swogic
//
//  Created by Ferran Pujol Camins on 04/05/2018.
//

public enum PlaceHolderCondition<I>: ChainElement {
    public typealias Literal = () -> ()

    case new
}

public struct Condition<I>: ChainElement {
    public typealias Literal = (I) -> Bool

    private let condition: Literal

    public init(_ literal: @escaping Literal) {
        condition = literal
    }

    public func evaluate(_ value: I) -> Bool {
        return condition(value)
    }
}

public struct MatchCondition<I: Equatable>: ChainElement {
    public typealias Literal = () -> I

    private let pattern: Literal

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
