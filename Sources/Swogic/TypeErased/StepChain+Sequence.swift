extension StepChain: Sequence {
    public class Iterator: IteratorProtocol {
        public typealias Element = ChainElement

        var chain: StepChainDataStructure?

        init (_ chain: StepChainDataStructure) {
            self.chain = chain
        }

        public func next() -> ChainElement? {

            switch chain {
            case .step(let step)?:
                chain = nil
                return step
            case .stepChain(let childChain, let step)?:
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
