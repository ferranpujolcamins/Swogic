public class TypeErasedStep: DomainStep {
    public var name: String

    let closure: (Any) -> Any

    init<I,O>(from dslStep: Step<I, O>) {
        name = dslStep.name
        closure = eraseType(dslStep.closure)
    }
}
