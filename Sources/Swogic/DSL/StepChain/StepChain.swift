//
//  StepChain.swift
//  SwiftGraph
//
//  Created by Ferran Pujol Camins on 03/05/2018.
//

public protocol AnyChainElement {
//    var erasedClosure: (Any) -> Any { get }
}

public enum ChainElement: Equatable {
    case step(TypeErasedStep)
    case condition(TypeErasedCondition)
    case placeholderCondition(PlaceHolderCondition)
    case matchCondition(TypeErasedMatchCondition)
}

internal indirect enum StepChainDataStructure {
    case step(ChainElement)
    case stepChain(StepChainDataStructure, ChainElement)

    private init(_ step: ChainElement) {
        self = .step(step)
    }

    public init<I, O>(_ step: Step<I, O>) {
        self.init(.step(TypeErasedStep(from: step)))
    }

//    public init<I>(_ condition: Condition<I>) {
//        self.init(.condition(TypeErasedCondition(from: condition)))
//    }
//
//    public init<I>(_ condition: MatchCondition<I>) {
//        self.init(.matchCondition(TypeErasedMatchCondition(from: condition)))
//    }

    public static func + (_ chain: StepChainDataStructure, _ newStep: ChainElement) -> StepChainDataStructure {
        switch chain {
        case .step(let step):
            return .stepChain(.step(newStep), step)

        case .stepChain (let innerChain, let step):
            return .stepChain(innerChain + newStep, step)
        }
    }

    public static func + <I, O>(_ chain: StepChainDataStructure, _ newStep: Step<I, O>) -> StepChainDataStructure {
        return chain + .step(TypeErasedStep(from: newStep))
    }

    public static func + <I>(_ chain: StepChainDataStructure, _ condition: Condition<I>) -> StepChainDataStructure {
        return chain + .condition(TypeErasedCondition(from: condition))
    }

    public static func + <I>(_ chain: StepChainDataStructure, _ condition: MatchCondition<I>) -> StepChainDataStructure {
        return chain + .matchCondition(TypeErasedMatchCondition(from: condition))
    }

    public static func + (_ chain: StepChainDataStructure, _ condition: PlaceHolderCondition) -> StepChainDataStructure {
        return chain + .placeholderCondition(condition)
    }
}

// What does copy means for chains? this depends on how chains can be reused
// Shall they be a struct?
public class StepChain<I, O> {

    internal var stepChainData: StepChainDataStructure

    internal init<I, O>(step: Step<I, O>) {
        self.stepChainData = StepChainDataStructure(step)
    }

    private init(stepChainData: StepChainDataStructure) {
        self.stepChainData = stepChainData
    }

    public static func --- (_ chain: StepChain<I, O>, _ condition: @escaping Condition<O>.Literal) -> StepChain<I, O> {
        return chain ---> Condition<O>(condition)
    }

    public static func --- (_ chain: StepChain<I, O>, _ placeholder: @escaping PlaceHolderCondition.Literal) -> StepChain<I, O> {
        return chain ---> PlaceHolderCondition.new
    }

    public static func ---> <U> (_ stepChain: StepChain<I, U>, _ newStep: Step<U, O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + newStep)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: Condition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: PlaceHolderCondition) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}

extension StepChain where O: Equatable {
    public static func --- (_ chain: StepChain<I, O>, _ condition: @escaping MatchCondition<O>.Literal) -> StepChain<I, O> {
        return chain ---> MatchCondition<O>(condition)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: MatchCondition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}
