extension Collection where Element: Equatable {
    /// If all the elements of the collection are equal, returns the unique element.
    /// If the collection is empty, or has different elements, returns nil.
    public var uniqueElement: Element? {
        get {
            guard let first = self.first else { return nil }
            for e in self.dropFirst() {
                if e != first {
                    return nil
                }
            }
            return first
        }
    }
}
