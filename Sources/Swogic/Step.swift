import Domain
import DSL
import Closure

class Step: Domain.Step {
    private var _name: String = ""
    var name: String {
        get {
            return _name
        }
        set(name) {
            _name = name
        }
    }

    let closure: (Any) -> Any

    init<I,O>(from dslStep: DSL.Step<I, O>) {
        _name = dslStep.name
        closure = Closure.eraseType(dslStep.closure)
    }
}
