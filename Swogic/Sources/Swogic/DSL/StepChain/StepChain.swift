public enum ChainElement: Hashable, CustomDebugStringConvertible {
    case step(TypeErasedStep)
    case process(TypeErasedProcess)
    case condition(TypeErasedCondition)
    case placeholderCondition(PlaceHolderCondition)
    case matchCondition(TypeErasedMatchCondition)
    case matchAfterProjectionCondition(TypeErasedMatchAfterProjectionCondition)

    public var debugDescription: String {
        switch self {

        case .step(let step):
            return step.debugDescription
        case .process(let process):
            return process.debugDescription
        case .condition(let condition):
            return condition.debugDescription
        case .placeholderCondition(_):
            return ""
        case .matchCondition(let condition):
            return condition.debugDescription
        case .matchAfterProjectionCondition(let condition):
            return condition.debugDescription
        }
    }
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

    public static func + <I, O>(_ chain: StepChainDataStructure, _ process: Process<I, O>) -> StepChainDataStructure {
        return chain + .process(TypeErasedProcess(from: process))
    }

    public static func + <I>(_ chain: StepChainDataStructure, _ condition: Condition<I>) -> StepChainDataStructure {
        return chain + .condition(TypeErasedCondition(from: condition))
    }

    public static func + <I>(_ chain: StepChainDataStructure, _ condition: MatchCondition<I>) -> StepChainDataStructure {
        return chain + .matchCondition(TypeErasedMatchCondition(from: condition))
    }

    public static func + <I>(_ chain: StepChainDataStructure, _ condition: MatchAfterProjectionCondition<I>) -> StepChainDataStructure {
        return chain + .matchAfterProjectionCondition(TypeErasedMatchAfterProjectionCondition(from: condition))
    }

    public static func + (_ chain: StepChainDataStructure, _ condition: PlaceHolderCondition) -> StepChainDataStructure {
        return chain + .placeholderCondition(condition)
    }
}

// What does copy means for chains? this depends on how chains can be reused
// Shall they be a struct?
public final class StepChain<I, O> {

    internal var stepChainData: StepChainDataStructure

    internal init<I, O>(step: Step<I, O>) {
        self.stepChainData = StepChainDataStructure(step)
    }

    private init(stepChainData: StepChainDataStructure) {
        self.stepChainData = stepChainData
    }

    public static func ---- (_ chain: StepChain<I, O>, _ condition: @escaping Condition<O>.Literal) -> StepChain<I, O> {
        return chain ---> Condition<O>(condition)
    }

    public static func ---- (_ chain: StepChain<I, O>, _ placeholder: @escaping PlaceHolderCondition.Literal) -> StepChain<I, O> {
        return chain ---> PlaceHolderCondition.new
    }

    public static func ---> <U> (_ stepChain: StepChain<I, U>, _ newStep: Step<U, O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + newStep)
    }

    public static func ---> <U> (_ stepChain: StepChain<I, U>, _ process: Process<U, O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + process)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: Condition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: PlaceHolderCondition) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}

extension StepChain where O: EquatableToAny {
    public static func ---- (_ chain: StepChain<I, O>, _ condition: @escaping MatchCondition<O>.Literal) -> StepChain<I, O> {
        return chain ---> MatchCondition<O>(condition)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: MatchCondition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}

extension StepChain where O: EquatableAfterProjection {
    public static func ---- (_ chain: StepChain<I, O>, _ condition: @escaping MatchAfterProjectionCondition<O>.Literal) -> StepChain<I, O> {
        return chain ---> MatchAfterProjectionCondition<O>(condition)
    }

    public static func ---> (_ stepChain: StepChain<I, O>, _ condition: MatchAfterProjectionCondition<O>) -> StepChain<I, O> {
        return StepChain(stepChainData: stepChain.stepChainData + condition)
    }
}
