public class TypeErasedStep: DomainStep, EquatableRepresentative {
    var representee: AnyObject

    public var name: String

    let closure: (Any) -> Any

    init<I,O>(from dslStep: Step<I, O>) {
        name = dslStep.name
        closure = eraseType(dslStep.closure)
        representee = dslStep
    }
}


protocol EquatableRepresentative: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool

    var representee: AnyObject { get };
}

extension EquatableRepresentative {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.representee === rhs.representee
    }
}
