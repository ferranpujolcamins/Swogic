//
//  StepChain.swift
//  SwiftGraph
//
//  Created by Ferran Pujol Camins on 03/05/2018.
//

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

struct StepChain<I, O> {
    private var stepChainData: StepChainDataStructure

    public init(step: AnyStep) {
        self.stepChainData = StepChainDataStructure(step)
    }

    private init(stepChainData: StepChainDataStructure) {
        self.stepChainData = stepChainData
    }

    static func ---> <U> (_ stepChain: StepChain<I, U>, _ newStep: Step<U, O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + newStep)
    }

    static func ---> (_ stepChain: StepChain<I, O>, _ condition: Condition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}

extension StepChain where O: Equatable {
    static func ---> (_ stepChain: StepChain<I, O>, _ condition: MatchCondition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}
