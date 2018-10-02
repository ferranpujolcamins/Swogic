//public protocol StepChainConvertible {
//    func asStepChain() -> StepChain
//}
//
//public class StepChain: Sequence, StepChainConvertible {
//    public typealias Element = ChainElement
//    public typealias Iterator = AnyStepChainIterator
//
//    init(step: Step) {
//
//    }
//
//    public func makeIterator() -> AnyStepChainIterator {
//        return ValidStepChainIterator(.step(Step({})))
//    }
//
//    public func asStepChain() -> StepChain {
//        return self
//    }
//}
