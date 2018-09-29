//
//  StepChain.swift
//  SwiftGraph
//
//  Created by Ferran Pujol Camins on 03/05/2018.
//

public protocol AnyStepChainP {}
public class AnyStepChain<S>: AnyStepChainP {}

fileprivate indirect enum StepChainDataStructure {
    case step(AnyStep)
    case stepChain(StepChainDataStructure, AnyStep)

    public init(_ step: AnyStep) {
        self = .step(step)
    }

    public static func + (_ chain: StepChainDataStructure, _ newStep: AnyStep) -> StepChainDataStructure {
        switch chain {
        case .step(let step):
            return .stepChain(.step(step), newStep)

        case .stepChain (let innerChain, let step):
            return .stepChain(innerChain + step, newStep)
        }
    }
}

// What does copy means for chains? this depends on how chains can be reused
public class StepChain<I, O>: AnyStepChain<I> {
    private var stepChainData: StepChainDataStructure

    internal init(step: AnyStep) {
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
