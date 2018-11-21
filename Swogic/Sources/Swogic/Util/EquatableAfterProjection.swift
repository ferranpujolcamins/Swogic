//
//  EquatableAfterProjection.swift
//  SwiftGraph
//
//  Created by Ferran Pujol Camins on 20/11/2018.
//

import Foundation

public protocol EquatableAfterProjection {
    associatedtype Projected: EquatableToAny

    static var projection: (Self) -> Projected { get }
}
