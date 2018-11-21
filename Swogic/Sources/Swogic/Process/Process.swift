import SwiftGraph

public class IndentedChainElement: Equatable {
    let element: ChainElement
    var indentation: Int = 0

    init(_ element: ChainElement) {
        self.element = element
    }

    public static func == (lhs: IndentedChainElement, rhs: IndentedChainElement) -> Bool {
        return lhs.element == rhs.element
    }
}

public class Process<I, O> {
    private let graph: UniqueElementsGraph<IndentedChainElement>
    private let initialElement: IndentedChainElement
    public init(_ chains: [StepChain<I, O>]) {
        let chains = chains.map({Array($0)})
        let graphs = chains
            .map({ $0.map({ IndentedChainElement($0) }) })
            .map({ UniqueElementsGraph<IndentedChainElement>(withPath: $0, directed: true)})

        guard let initialStep = chains.compactMap({ $0.first }).uniqueElement else {
            preconditionFailure("Initial step not unique")
        }

        self.initialElement = IndentedChainElement(initialStep)

        graph = UniqueElementsGraph(unionOf: graphs)
    }

    public var evaluationLog = ""
    // Initialized with a dummy value that will be replaced
    private var lastVisitedElement: IndentedChainElement!

    public func evaluate(_ p: I) -> O? {
        var evaluations = Dictionary<ChainElement, Any>()

        var firstFinalResult: Any? = nil

        guard let initialIndex = graph.indexOfVertex(initialElement),
              case .step(let initialStep) = initialElement.element else { return nil }

        // Initial step, repeated code
        let partialResult = initialStep.closure(p)
        evaluations[initialElement.element] = partialResult
        if ( graph.edgesForIndex(initialIndex).count == 0 && firstFinalResult == nil) {
            firstFinalResult = partialResult
        }
        evaluationLog = initialStep.debugDescription
        lastVisitedElement = initialElement

        _ = graph.dfs(fromIndex: initialIndex,
                  goalTest: { _ in false },
                  visitOrder: { $0.reversed() },
                  reducer: { (edge) -> Bool in

            let prevElementIndexed = graph.vertexAtIndex(edge.u)
            let elementIndexed = graph.vertexAtIndex(edge.v)

            let prevElement = prevElementIndexed.element
            let element = elementIndexed.element

            let newIndentation = logStep(prevElement: prevElementIndexed, element: elementIndexed)
            elementIndexed.indentation = newIndentation
            lastVisitedElement = elementIndexed
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

            case .matchAfterProjectionCondition(let condition):
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

    private func logStep(prevElement: IndentedChainElement, element: IndentedChainElement) -> Int {
        let logInitialCount = evaluationLog.count + 6
        if lastVisitedElement.indentation > prevElement.indentation + 6 {
            let indentation = prevElement.indentation + prevElement.element.debugDescription.count
            evaluationLog += "\n"
            evaluationLog += String(repeating: " ", count: indentation)
        }
        switch (prevElement.element, element.element) {

        case (_, .step(let step)):
            evaluationLog += " ---> "
            evaluationLog += step.debugDescription

        case (.step, .condition(let condition)):
            evaluationLog += " ---- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (.step, .matchCondition(let condition)):
            evaluationLog += " ---- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (.step, .matchAfterProjectionCondition(let condition)):
            evaluationLog += " ---- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (_, _):
            break
        }

        return logInitialCount
    }
}
