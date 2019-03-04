extension StateSequence: Sequence {
    public class Iterator: IteratorProtocol {
        public typealias Element = StateSequenceElement

        var chain: StateSequenceDataStructure?

        init (_ chain: StateSequenceDataStructure) {
            self.chain = chain
        }

        public func next() -> StateSequenceElement? {

            switch chain {
            case .state(let step)?:
                chain = nil
                return step
            case .stateSequence(let childChain, let step)?:
                chain = childChain
                return step
            case .none:
                return nil
            }
        }
    }

    public func makeIterator() -> Iterator {
        return Iterator(self.stepChainData)
    }
}
