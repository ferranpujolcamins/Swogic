public final class State<StateType>: Nameable {

    public let state: StateType

    private var _name: String = ""
    public var name: String {
        get {
            return _name
        }
        set(name) {
            _name = name
        }
    }

    public init(_ state: StateType) {
        self.state = state
    }

    public static prefix func ! (_ step: State<StateType>) -> State<StateType> {
        return step.copy()
    }

//    public static func ---> <U> (_ lhs: State<StateType>, _ rhs: State<StateType>) -> SateSequence<StateType> {
//        return SateSequence(step: lhs) ---> rhs
//    }
//
//    public static func ---> <U> (_ step: State<StateType>, _ process: StateMachine<StateType>) -> SateSequence<StateType> {
//        return StepChain(step: step) ---> process
//    }

    public static func ---- <EventType>(_ step: State<StateType>, _ condition: @escaping Condition<EventType>.Literal) -> StateSequence<StateType> {
        return StateSequence(state: step) ---> Condition<EventType>(condition)
    }

    public static func ---- <EventType>(_ step: State<StateType>, _ condition: Condition<EventType>) -> StateSequence<StateType> {
        return StateSequence(state: step) ---> condition
    }

    public static func ---- (_ step: State<StateType>, _ placeholder: @escaping PlaceHolderCondition.Literal) -> StateSequence<StateType> {
        return StateSequence(state: step) ---> PlaceHolderCondition.new
    }
}

extension State where StateType: EquatableToAny {
    public static func ---- <EventType>(_ step: State<StateType>, _ condition: @escaping MatchCondition<EventType>.Literal) -> StateSequence<StateType> {
        return StateSequence(state: step) ---> MatchCondition<EventType>(condition)
    }

    public static func ---- <EventType> (_ step: State<StateType>, _ condition: MatchCondition<EventType>) -> StateSequence<StateType> {
        return StateSequence(state: step) ---> condition
    }
}

extension State where StateType: EquatableAfterProjection {
    public static func ---- <EventType>(_ step: State<StateType>, _ condition: @escaping MatchAfterProjectionCondition<EventType>.Literal) -> StateSequence<StateType> {
        return StateSequence(state: step) ---> MatchAfterProjectionCondition<EventType>(condition)
    }

    public static func ---- <EventType>(_ step: State<StateType>, _ condition: MatchAfterProjectionCondition<EventType>) -> StateSequence<StateType> {
        return StateSequence(state: step) ---> condition
    }
}
