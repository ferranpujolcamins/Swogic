import XCTest
@testable import Swogic

// we use this tests, among other things, to test that the access levels set are correct
final class SwogicTests: XCTestCase {

    let step1 = ExecutionStep<String, Int> { (str) -> Int in
        str.count
    }
    let step2 = ExecutionStep<Int, Double> { (i: Int) -> Double in
        Double(i) + 3.5
    }
    let step3 = ExecutionStep<Double, String> { (d) -> String in
        "Number is: " + String(d)
    }

    func testSingleStepFlow() {
        _ = Flow<String, Int>([
            =>step1
        ])
    }

    func testMultipleStepFlow() {
        _ = Flow<String, Int>([
            =>step1,
            step2
        ])
    }

    func testSingleChainFlow() {
        _ = Flow<String, Int>([
            =>step1 --- { $0 < 2 } ---> step2 ---> step3 --- { $0.count < 4 } ---> step1
        ])
    }

    func testMultipleChainFlow() {
        _ = Flow<String, Int>([
            =>step1 --- { $0 < 2 } ---> step2 ---> step3 --- { $0.count < 4 } ---> step1,
                                        step2 ---> *step3
        ])
    }

    func testNew() {

        // Actions can be values or class! If value, we add new, if class, we try to match??
        let step1 = ExecutionStep<String, Int> { (str) -> Int in
            str.count
        }
        let step2 = ExecutionStep<Int, Double> { (i: Int) -> Double in
            Double(i) + 3.5
        }
        let step3 = ExecutionStep<Double, String> { (d) -> String in
            "Number is: " + String(d)
        }

        // => marks the entry point. if there are unreachable nodes, warning is issued. no entry point or more than one is a runtime error
        =>step1 --- { $0 < 2 } ---> step2 ---> step3 --- { $0.count < 4 } ---> step1
                                    step2 ---> *step3

        // Two times the same branch
        =>step1  --->  step2         ---> step3
          step1  --->  step2.copy()  ---> *step3

        // Only one branch
        =>step1  --->  step2  ---> step3
          step1  --->  step2  ---> step3

        // Reference to two specific copies of same step:
        let step2c = *step2
        let step3c = step3.copy()

        =>step1 ---> step2  ---> step3
          step1 ---> step2c ---> step3c
          step1 ---> step2  ---> step3c
          step1 ---> step2c ---> step3

        // what about conditions?
        =>step1 --- { $0 < 2 } ---> step2 ---> step3

        // Only one condition between two graphs, to reduce risk of mistakes.
        // At, the end, you can always make a copy of the arriving step...
        // So, the following should throw a runtime error
        =>step1 --- { $0 < 2 } ---> step2 ---> step3
          step1 --- { $0 < 2 } ---> step2 ---> step3

        // If edges have no condition, the paths are merged normally
        =>step1  ---> step2 ---> step3
          step1  ---> step2 ---> *step3

        // If edge has a condition, a placeholder has to be used in the second edge to indicate that we are refering to an existing edge
        =>step1 --- { $0 > 4 } ---> step2 ---> step3
          step1 --- {   ()   } ---> step2 ---> step3

        //step1 ---> { $0 > 4} // this should not be allowed
    }


    static var allTests = [
        ("testNew", testNew),
    ]
}
