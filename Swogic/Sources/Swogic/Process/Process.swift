import SwiftGraph

public class Process<I, O> {
    private let graph: UniqueElementsGraph<ChainElement>
    private let initialElement: ChainElement
    public init(_ chains: [StepChain<I, O>]) {
        let chains = chains.map({Array($0)})
        let graphs = chains.map({ UniqueElementsGraph<ChainElement>(withPath: $0, directed: true)})

        guard let initialStep = chains.compactMap({ $0.first }).uniqueElement else {
            preconditionFailure("Initial step not unique")
        }

        self.initialElement = initialStep

        graph = UniqueElementsGraph(unionOf: graphs)
    }

    public var evaluationLog = ""

    public func evaluate(_ p: I) -> O? {
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
        evaluationLog = initialStep.debugDescription

        _ = graph.dfs(fromIndex: initialIndex,
                  goalTest: { _ in false },
                  visitOrder: { $0.reversed() },
                  reducer: { (edge) -> Bool in

            let prevElement = graph.vertexAtIndex(edge.u)
            let element = graph.vertexAtIndex(edge.v)
            logStep(prevElement: prevElement, element: element)
            switch element {

            case .step(let step):
                let partialResult = step.closure(evaluations[prevElement]!)
                evaluations[element] = partialResult
                if (graph.edgesForIndex(edge.v).count == 0 && firstFinalResult == nil) {
                    firstFinalResult = partialResult
                }

            case .condition(let condition):
                let p = evaluations[prevElement]!
                evaluations[element] = p
                return condition.evaluate(p)

            case .matchCondition(let condition):
                let p = evaluations[prevElement]!
                evaluations[element] = p
                return condition.evaluate(p)

            case .placeholderCondition(_):
                break
            }
            return true
        })
        return firstFinalResult.flatMap({ $0 as? O})
    }

    private func logStep(prevElement: ChainElement, element: ChainElement) {
        switch (prevElement, element) {

        case (_, .step(let step)):
            evaluationLog += " ---> "
            evaluationLog += step.debugDescription

        case (.step, .condition(let condition)):
            evaluationLog += " --- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (.step, .matchCondition(let condition)):
            evaluationLog += " --- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (_, _):
            break
        }
    }
}
