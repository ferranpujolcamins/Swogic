//
//  StepChain.swift
//  SwiftGraph
//
//  Created by Ferran Pujol Camins on 03/05/2018.
//

public protocol ChainElement {}

internal indirect enum StepChainDataStructure {
    case step(ChainElement)
    case stepChain(StepChainDataStructure, ChainElement)

    public init(_ step: ChainElement) {
        self = .step(step)
    }

    public static func + (_ chain: StepChainDataStructure, _ newStep: ChainElement) -> StepChainDataStructure {
        switch chain {
        case .step(let step):
            return .stepChain(.step(newStep), step)

        case .stepChain (let innerChain, let step):
            return .stepChain(innerChain + newStep, step)
        }
    }
}

// What does copy means for chains? this depends on how chains can be reused
// Shall they be a struct?
public class StepChain<I, O> {

    private var stepChainData: StepChainDataStructure

    internal init(step: ChainElement) {
        self.stepChainData = StepChainDataStructure(step)
    }

    private init(stepChainData: StepChainDataStructure) {
        self.stepChainData = stepChainData
    }

    public static func --- (_ chain: StepChain<I, O>, _ condition: @escaping Condition<O>.Literal) -> StepChain<I, O> {
        return chain ---> Condition<O>(condition)
    }

    public static func --- (_ chain: StepChain<I, O>, _ placeholder: @escaping PlaceHolderCondition<O>.Literal) -> StepChain<I, O> {
        return chain ---> PlaceHolderCondition<O>.new
    }

    public static func ---> <U> (_ stepChain: StepChain<I, U>, _ newStep: Step<U, O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + newStep)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: Condition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: PlaceHolderCondition<O>) -> StepChain<I, O> {
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
