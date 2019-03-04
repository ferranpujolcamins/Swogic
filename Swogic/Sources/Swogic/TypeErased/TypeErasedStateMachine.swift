public class TypeErasedStateMachine: HashableRepresentative, EvaluationLog, CustomDebugStringConvertible {
    var representee: AnyObject

    public var name: String

    let closure: (Any) -> Any

    init<I,O>(from stateMachine: StateMachine<I, O>) {
        name = stateMachine.name
        closure = eraseType({
            dslProcess.evaluate($0) as Any
        })
        representee = stateMachine
    }

    public var evaluationLog: String {
        return (representee as! EvaluationLog).evaluationLog
    }

    public var debugDescription: String {
        get {
            if let representee = representee as? CustomDebugStringConvertible {
                return representee.debugDescription
            } else {
                return ""
            }
        }
    }
}
