public class TypeErasedCondition: DomainCondition, EquatableRepresentative {
    var representee: AnyObject

    let closure: (Any) -> Any

    init<I>(from dslCondition: Condition<I>) {
        closure = eraseType(dslCondition.condition)
        representee = dslCondition
    }
}

public class TypeErasedMatchCondition: DomainMatchCondition, EquatableRepresentative {
    var representee: AnyObject

    let closure: (Any) -> Any

    init<I>(from dslCondition: MatchCondition<I>) {
        closure = eraseType(dslCondition.pattern)
        representee = dslCondition
    }
}
