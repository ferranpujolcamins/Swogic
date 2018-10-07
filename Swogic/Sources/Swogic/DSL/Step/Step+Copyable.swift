extension Step: Copyable {
    public func copy() -> Step<I, O> {
        let step = Step<I, O>(closure)
        step.name = name
        return step
    }
}
