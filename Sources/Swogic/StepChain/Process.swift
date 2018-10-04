import SwiftGraph

public class Process<I, O> {
    let graph: UniqueElementsGraph<ChainElement>
    init(_ chains: [StepChain<I, O>]) {
        let graphs = chains.map{ UniqueElementsGraph<ChainElement>(withPath: Array($0), directed: true) }
        graph = UniqueElementsGraph(unionOf: graphs)
    }
}
