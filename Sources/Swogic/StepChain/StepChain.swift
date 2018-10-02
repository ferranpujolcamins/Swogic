//
//  StepChain.swift
//  SwiftGraph
//
//  Created by Ferran Pujol Camins on 03/05/2018.
//

public class StepChain: Sequence {
    public typealias Element = Step
    public typealias Iterator = AnyStepChainIterator

    public func makeIterator() -> AnyStepChainIterator {
        return ValidStepChainIterator(.step(ExecutionStep({})))
    }
}

internal indirect enum StepChainDataStructure {
    case step(Step)
    case stepChain(StepChainDataStructure, Step)

    public init(_ step: Step) {
        self = .step(step)
    }

    public static func + (_ chain: StepChainDataStructure, _ newStep: Step) -> StepChainDataStructure {
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
public class ValidStepChain<I, O>: StepChain, CustomDebugStringConvertible {

    private var stepChainData: StepChainDataStructure

    public var debugDescription: String {
        get {
            var str = ""
            for s in self {
                if let es = s as? CustomDebugStringConvertible {
                    str += es.debugDescription
                } else {
                    str += "?"
                }
                str += "\n"
            }
            return str
        }
    }

    internal init(step: Step) {
        self.stepChainData = StepChainDataStructure(step)
    }

    private init(stepChainData: StepChainDataStructure) {
        self.stepChainData = stepChainData
    }

    public static func --- (_ chain: ValidStepChain<I, O>, _ condition: @escaping Condition<O>.Literal) -> ValidStepChain<I, O> {
        return chain ---> Condition<O>(condition)
    }

    public static func --- (_ chain: ValidStepChain<I, O>, _ placeholder: @escaping PlaceHolderCondition<O>.Literal) -> ValidStepChain<I, O> {
        return chain ---> PlaceHolderCondition<O>.new
    }

    public static func ---> <U> (_ stepChain: ValidStepChain<I, U>, _ newStep: ExecutionStep<U, O>) -> ValidStepChain<I, O> {
        return ValidStepChain(stepChainData: stepChain.stepChainData + newStep)
    }

    public static func ---> (_ stepChain: ValidStepChain<I, O>, _ condition: Condition<O>) -> ValidStepChain<I, O> {
        return ValidStepChain(stepChainData: stepChain.stepChainData + condition)
    }

    public static func ---> (_ stepChain: ValidStepChain<I, O>, _ condition: PlaceHolderCondition<O>) -> ValidStepChain<I, O> {
        return ValidStepChain(stepChainData: stepChain.stepChainData + condition)
    }


    public override func makeIterator() -> AnyStepChainIterator {
        return ValidStepChainIterator(stepChainData)
    }
}

extension ValidStepChain where O: Equatable {
    public static func --- (_ chain: ValidStepChain<I, O>, _ condition: @escaping MatchCondition<O>.Literal) -> ValidStepChain<I, O> {
        return chain ---> MatchCondition<O>(condition)
    }

    public static func ---> (_ stepChain: ValidStepChain<I, O>, _ condition: MatchCondition<O>) -> ValidStepChain<I, O> {
        return ValidStepChain(stepChainData: stepChain.stepChainData + condition)
    }
}
