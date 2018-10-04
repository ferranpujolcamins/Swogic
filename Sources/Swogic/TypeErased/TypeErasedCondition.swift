public class TypeErasedCondition: DomainCondition {
    let closure: (Any) -> Any

    init<I>(from dslCondition: Condition<I>) {
        closure = eraseType(dslCondition.condition)
    }
}

public class TypeErasedMatchCondition: DomainMatchCondition {
    let closure: (Any) -> Any

    init<I>(from dslCondition: MatchCondition<I>) {
        closure = eraseType(dslCondition.pattern)
    }
}
