public func eraseType<I>(_ c: @escaping (I) -> Any) -> (Any) -> Any {
    return { a in c(a as! I) }
}
