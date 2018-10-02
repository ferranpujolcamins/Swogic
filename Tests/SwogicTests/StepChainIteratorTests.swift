import XCTest
@testable import Swogic

final class IteratorTests: XCTestCase {

    var step1 = ExecutionStep<String, Int> { (str) -> Int in
        str.count
    }
    var step2 = ExecutionStep<Int, Double> { (i: Int) -> Double in
        Double(i) + 3.5
    }
    var step3 = ExecutionStep<Double, String> { (d) -> String in
        "Number is: " + String(d)
    }

    override func setUp() {
        step1.name = "step1"
        step2.name = "step2"
        step3.name = "step3"
    }

    func testIterator() {
        let chain = =>step1 --- { $0 < 2 } ---> step2 ---> step3 --- { $0.count < 4 } ---> step1 ---> step2

        var count = 0
        for _ in chain {
            count += 1
        }
        // This is so we can check that the iterator is not consumed
        for _ in chain {
            count += 1
            count -= 1
        }
        XCTAssertEqual(count, 7, "fail")

        print(chain)

        let c: AnySequence<Step> = chain.dropFirst(3)
        XCTAssertTrue(c.makeIterator().next()! as! ExecutionStep<Double, String> === step3)
    }
}
