import SwiftGraph

public class IndentedChainElement: Equatable, CustomDebugStringConvertible {
    let element: ChainElement
    var indentation: Int = 0

    init(_ element: ChainElement) {
        self.element = element
    }

    public static func == (lhs: IndentedChainElement, rhs: IndentedChainElement) -> Bool {
        return lhs.element == rhs.element
    }

    public var debugDescription: String {
        return element.debugDescription
    }
}

protocol EvaluationLog {
    var evaluationLog: String { get }
}

public final class Process<I, O>: Nameable, EvaluationLog {

    public var name: String = ""

    private let graph: UniqueElementsGraph<IndentedChainElement>
    private let initialElement: IndentedChainElement

    // TODO: overload for only one chain
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

    private init(graph: UniqueElementsGraph<IndentedChainElement>, initialElement: IndentedChainElement, name: String, evaluationLog: String, lastVisitedElement: IndentedChainElement!) {
        self.graph = graph
        self.initialElement = initialElement
        self.name = name
        self.evaluationLog = evaluationLog
        self.lastVisitedElement = lastVisitedElement
    }

    public func copy() -> Process<I, O> {
        return Process(graph: self.graph,
                       initialElement: self.initialElement,
                       name: self.name,
                       evaluationLog: self.evaluationLog,
                       lastVisitedElement: self.lastVisitedElement)
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
        if (graph.edgesForIndex(initialIndex).count == 0 && firstFinalResult == nil) {
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

            var shouldVisitNeighbours = true

            switch element {

            case .step(let step):
                let partialResult = step.closure(evaluations[prevElement]!)
                evaluations[element] = partialResult
                if (graph.edgesForIndex(edge.v).count == 0 && firstFinalResult == nil) {
                    firstFinalResult = partialResult
                }

            case .process(let process):
                let partialResult = process.closure(evaluations[prevElement]!)
                evaluations[element] = partialResult
                if (graph.edgesForIndex(edge.v).count == 0 && firstFinalResult == nil) {
                    firstFinalResult = partialResult
                }

            case .condition(let condition):
                let p = evaluations[prevElement]!
                evaluations[element] = p
                shouldVisitNeighbours = condition.evaluate(p)

            case .matchCondition(let condition):
                let p = evaluations[prevElement]!
                evaluations[element] = p
                shouldVisitNeighbours = condition.evaluate(p)

            case .matchAfterProjectionCondition(let condition):
                let p = evaluations[prevElement]!
                evaluations[element] = p
                shouldVisitNeighbours = condition.evaluate(p)

            case .placeholderCondition(_):
                // TODO: test placeholder condition
                break
            }

            let newIndentation = logStep(prevElement: prevElementIndexed, element: elementIndexed)
            elementIndexed.indentation = newIndentation
            lastVisitedElement = elementIndexed

            return shouldVisitNeighbours
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

        case (_, .process(let process)):
            evaluationLog += " ---> "
            evaluationLog += process.evaluationLog

        case (.step, .condition(let condition)),
             (.process, .condition(let condition)):
            evaluationLog += " ---- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (.step, .matchCondition(let condition)),
             (.process, .matchCondition(let condition)):
            evaluationLog += " ---- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (.step, .matchAfterProjectionCondition(let condition)),
             (.process, .matchAfterProjectionCondition(let condition)):
            evaluationLog += " ---- "
            evaluationLog += "{"+condition.debugDescription+"}"

        case (.condition(_), .condition(_)),
             (.placeholderCondition(_), .condition(_)),
             (.matchCondition(_), .condition(_)),
             (.matchAfterProjectionCondition(_), .condition(_)),
             (.condition(_), .matchCondition(_)),
             (.placeholderCondition(_), .matchCondition(_)),
             (.matchCondition(_), .matchCondition(_)),
             (.matchAfterProjectionCondition(_), .matchCondition(_)),
             (.condition(_), .matchAfterProjectionCondition(_)),
             (.placeholderCondition(_), .matchAfterProjectionCondition(_)),
             (.matchCondition(_), .matchAfterProjectionCondition(_)),
             (.matchAfterProjectionCondition(_), .matchAfterProjectionCondition(_)),
             (_, .placeholderCondition(_)):
            break
        }

        return logInitialCount
    }

    public static prefix func ! (_ process: Process<I, O>) -> Process<I, O> {
        return process.copy()
    }
}
