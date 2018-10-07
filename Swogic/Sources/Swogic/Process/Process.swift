import SwiftGraph

public class Process<I, O> {
    let graph: UniqueElementsGraph<ChainElement>
    let dfs: DFS<UniqueElementsGraph<ChainElement>>
    let initialElement: ChainElement
    init(_ chains: [StepChain<I, O>]) {
        let chains = chains.map({Array($0)})
        let graphs = chains.map({ UniqueElementsGraph<ChainElement>(withPath: $0, directed: true)})

        guard let initialStep = chains.compactMap({ $0.first }).uniqueElement else {
            preconditionFailure("Initial step not unique")
        }

        self.initialElement = initialStep

        graph = UniqueElementsGraph(unionOf: graphs)
        dfs = DFS(on: graph) //set order
    }

    func evaluate(_ p: I) -> O? {
        var evaluations = Dictionary<ChainElement, Any>()

        var firstFinalResult: Any? = nil

        guard let initialIndex = graph.indexOfVertex(initialElement),
              case .step(let initialStep) = initialElement else { return nil }

        // Initial step, repeated code
        let partialResult = initialStep.closure(p)
        evaluations[initialElement] = partialResult
        if ( graph.edgesForIndex(initialIndex).count == 0 && firstFinalResult == nil) {
            firstFinalResult = partialResult
        }

        // TODO: use the return value to know the first finalResults
        dfs.from(initialIndex, goalTest: { _ in false }, reducer: { (edge) -> Bool in

            let prevElement = graph.vertexAtIndex(edge.u)
            let element = graph.vertexAtIndex(edge.v)

            switch element {

            case .step(let step):
                let partialResult = step.closure(evaluations[prevElement]!)
                evaluations[element] = partialResult
                if ( graph.edgesForIndex(edge.v).count == 0 && firstFinalResult == nil) {
                    firstFinalResult = partialResult
                }

            case .condition(let condition):
                let p = evaluations[prevElement]!
                evaluations[element] = p
                return condition.closure(p) as? Bool ?? false

            case .matchCondition(let condition):
                let p = evaluations[prevElement]!
                evaluations[element] = p
                return condition.closure(p) as? Bool ?? false

            case .placeholderCondition(_):
                break
            }
            print(evaluations)
            return true
        })
        return firstFinalResult.flatMap({ $0 as? O})
    }
}
