//
//  StepChain.swift
//  SwiftGraph
//
//  Created by Ferran Pujol Camins on 03/05/2018.
//
//
//fileprivate indirect enum StepChainDataStructure {
//    case step(AnyStep)
//    case stepChain(StepChainDataStructure, AnyStep)
//
//    init(_ step: AnyStep) {
//        self = .step(step)
//    }
//
//    static func + (_ chain: StepChainDataStructure, _ newStep: AnyStep) -> StepChainDataStructure {
//        switch chain {
//        case .step(let step):
//            return .stepChain(.step(step), newStep)
//
//        case .stepChain (let innerChain, let step):
//            return .stepChain(innerChain + step, newStep)
//        }
//    }
//}
//
//struct StepChain<I: Swogicable, O: Swogicable> {
//    private var stepChainData: StepChainDataStructure
//
//    private init(stepChainData: StepChainDataStructure) {
//
//    }
//
//    static func ------> <U> (_ stepChain: StepChain<I, U>, _ newStep: Step<U, O>) -> StepChain<I, O> {
//        return StepChain(stepChainData: stepChain.stepChainData + newStep)
//    }
//}

