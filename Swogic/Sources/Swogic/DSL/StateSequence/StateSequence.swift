public enum StateSequenceElement: Hashable, CustomDebugStringConvertible {
    case state(TypeErasedState)
    case stateMachine(TypeErasedStateMachine)
    case condition(TypeErasedCondition)
    case placeholderCondition(PlaceHolderCondition)
    case matchCondition(TypeErasedMatchCondition)
    case matchAfterProjectionCondition(TypeErasedMatchAfterProjectionCondition)

    public var debugDescription: String {
        switch self {

        case .state(let state):
            return state.debugDescription
        case .stateMachine(let stateMachine):
            return stateMachine.debugDescription
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

internal indirect enum StateSequenceDataStructure {
    case state(StateSequenceElement)
    case stateSequence(StateSequenceDataStructure, StateSequenceElement)

    private init(_ step: StateSequenceElement) {
        self = .state(step)
    }

    public init<StateType>(_ state: State<StateType>) {
        self.init(.state(TypeErasedState(from: state)))
    }

    public static func + (_ sequence: StateSequenceDataStructure, _ newStep: StateSequenceElement) -> StateSequenceDataStructure {
        switch sequence {
        case .state(let step):
            return .stateSequence(.state(newStep), step)

        case .stateSequence (let innerChain, let step):
            return .stateSequence(innerChain + newStep, step)
        }
    }

    public static func + <StateType>(_ sequence: StateSequenceDataStructure, _ newState: State<StateType>) -> StateSequenceDataStructure {
        return sequence + .state(TypeErasedState(from: newState))
    }

    public static func + <StateType, EventType, EffectType>(_ sequence: StateSequenceDataStructure, _ stateMachine: StateMachine<StateType, EventType, EffectType>) -> StateSequenceDataStructure {
        return sequence + .stateMachine(TypeErasedStateMachine(from: stateMachine))
    }

    public static func + <I>(_ sequence: StateSequenceDataStructure, _ condition: Condition<I>) -> StateSequenceDataStructure {
        return sequence + .condition(TypeErasedCondition(from: condition))
    }

    public static func + <I>(_ sequence: StateSequenceDataStructure, _ condition: MatchCondition<I>) -> StateSequenceDataStructure {
        return sequence + .matchCondition(TypeErasedMatchCondition(from: condition))
    }

    public static func + <I>(_ sequence: StateSequenceDataStructure, _ condition: MatchAfterProjectionCondition<I>) -> StateSequenceDataStructure {
        return sequence + .matchAfterProjectionCondition(TypeErasedMatchAfterProjectionCondition(from: condition))
    }

    public static func + (_ sequence: StateSequenceDataStructure, _ condition: PlaceHolderCondition) -> StateSequenceDataStructure {
        return sequence + .placeholderCondition(condition)
    }
}

// What does copy means for chains? this depends on how chains can be reused
// Shall they be a struct?
public final class StateSequence<StateType> {

    internal var stateSequenceData: StateSequenceDataStructure

    internal init<StateType>(state: State<StateType>) {
        self.stateSequenceData = StateSequenceDataStructure(state)
    }

    private init(stateSequenceData: StateSequenceDataStructure) {
        self.stateSequenceData = stateSequenceData
    }

    public static func ---- <EventType> (_ sequence: StateSequence<StateType>, _ condition: @escaping Condition<EventType>.Literal) -> StateSequence<StateType> {
        return sequence ---> Condition<EventType>(condition)
    }

    public static func ---- (_ sequence: StateSequence<StateType>, _ placeholder: @escaping PlaceHolderCondition.Literal) -> StateSequence<StateType> {
        return sequence ---> PlaceHolderCondition.new
    }

    public static func ---> <U> (_ sequence: StateSequence<StateType>, _ newStep: State<StateType>) -> StateSequence<StateType> {
        return StateSequence(stateSequenceData: sequence.stateSequenceData + newStep)
    }

    public static func ---> <EventType, EffectType> (_ sequence: StateSequence<StateType>, _ stateMachine: StateMachine<StateType, EventType, EffectType>) -> StateSequence<StateType> {
        return StateSequence(stateSequenceData: sequence.stateSequenceData + stateMachine)
    }

    public static func ---> <EventType> (_ sequence: StateSequence<StateType>, _ condition: Condition<EventType>) -> StateSequence<StateType> {
        return StateSequence(stateSequenceData: sequence.stateSequenceData + condition)
    }

    public static func ---> (_ sequence: StateSequence<StateType>, _ condition: PlaceHolderCondition) -> StateSequence<StateType> {
        return StateSequence(stateSequenceData: sequence.stateSequenceData + condition)
    }
}

extension StateSequence where StateType: EquatableToAny {
    public static func ---- <EventType>(_ sequence: StateSequence<StateType>, _ condition: @escaping MatchCondition<EventType>.Literal) -> StateSequence<StateType> {
        return sequence ---> MatchCondition<EventType>(condition)
    }

    public static func ---> <EventType>(_ stepChain: StateSequence<StateType>, _ condition: MatchCondition<EventType>) -> StateSequence<StateType> {
        return StateSequence(stateSequenceData: sequence.stateSequenceData + condition)
    }
}

extension StateSequence where StateType: EquatableAfterProjection {
    public static func ---- <EventType>(_ sequence: StateSequence<StateType>, _ condition: @escaping MatchAfterProjectionCondition<EventType>.Literal) -> StateSequence<StateType> {
        return sequence ---> MatchAfterProjectionCondition<EventType>(condition)
    }

    public static func ---> <EventType>(_ sequence: StateSequence<StateType>, _ condition: MatchAfterProjectionCondition<EventType>) -> StateSequence<StateType> {
        return StateSequence(stateSequenceData: sequence.stateSequenceData + condition)
    }
}
