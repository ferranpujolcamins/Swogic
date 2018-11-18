import XCTest
@testable import Swogic

final class StepChainSequenceTests: XCTestCase {

    var step1: Step<String, Int> = { (str) -> Int in
        str.count
    } ~ "step1"
    var step2: Step<Int, Double> = { (i: Int) -> Double in
        Double(i) + 3.5
    } ~ "step2"
    var step3: Step<Double, String> = { (d) -> String in
        "Number is: " + String(d)
    } ~ "step3"

    func testIterator() {
        let chain = step1 ---- { $0 < 2 } ---> step2 ---> step3 ---- { $0.count < 4 } ---> step1 ---> step2

        var firstCount = 0
        for _ in chain {
            firstCount += 1
        }

        var secondCount = 0
        for _ in chain {
            secondCount += 1
        }
        XCTAssertEqual(firstCount, 7, "Sequence has the wrong number of items")
        XCTAssertEqual(secondCount, 7, "Sequence is consumed when iterated")

        let c: AnySequence<ChainElement> = chain.dropFirst(3)

        guard case .step(let step)? = c.makeIterator().next() else {
            XCTFail("Iterator didn't return a step")
            return
        }

        XCTAssertTrue(step.representee === step3, "Iterator didn't return the expected step")
    }
}
