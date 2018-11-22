public class TypeErasedProcess: HashableRepresentative, EvaluationLog, CustomDebugStringConvertible {
    var representee: AnyObject

    public var name: String

    let closure: (Any) -> Any

    init<I,O>(from dslProcess: Process<I, O>) {
        name = dslProcess.name
        closure = eraseType({
            dslProcess.evaluate($0) as Any
        })
        representee = dslProcess
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
