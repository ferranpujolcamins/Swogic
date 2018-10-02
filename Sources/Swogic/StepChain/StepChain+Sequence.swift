//import Foundation
//
//public class AnyStepChainIterator: IteratorProtocol {
//    public typealias Element = ChainElement
//
//    public func next() -> ChainElement? {
//        return nil
//    }
//}
//
//public class ValidStepChainIterator: AnyStepChainIterator {
//
//    var chain: StepChainDataStructure?
//
//    init (_ chain: StepChainDataStructure) {
//        self.chain = chain
//    }
//
//    public override func next() -> ChainElement? {
//        
//        switch chain {
//        case .step(let step)?:
//            chain = nil
//            return step
//        case .stepChain(let childChain, let step)?:
//            chain = childChain
//            return step
//        case .none:
//            return nil
//        }
//    }
//}
