extension Step: Copyable {
    public func copy() -> Step<I, O> {
        return Step<I, O>(closure)
    }
}
