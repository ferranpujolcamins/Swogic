extension State: Copyable {
    public func copy() -> State<I, O> {
        let step = State<I, O>(closure)
        step.name = name
        return step
    }
}
