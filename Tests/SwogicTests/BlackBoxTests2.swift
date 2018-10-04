import XCTest
@testable import Swogic

// we use this tests, among other things, to test that the access levels set are correct
final class SwogicTests: XCTestCase {

    let step1 = Step<String, Int> { (str) -> Int in
        str.count
    }
    let step2 = Step<Int, Double> { (i: Int) -> Double in
        Double(i) + 3.5
    }
    let step3 = Step<Double, String> { (d) -> String in
        "Number is: " + String(d)
    }

    override func setUp() {
        step1.name = "step1"
        step2.name = "step2"
        step3.name = "step3"
    }

    func testMultipleChainFlow() {
        let a = step1 --- { $0 < 2 } ---> step2 ---> step3 --- { $0.count < 4 } ---> step1
    }

    func testGraph() {
        // Two times the same branch
        let g1 = Process([
            step1  --->  step2         ---> step3,
            step1  --->  step2.copy()  ---> !step3
        ])

        // Only one branch
        let g2 = Process([
            step1  --->  step2  ---> step3,
            step1  --->  step2  ---> step3
        ])
    }

    static var allTests = [ 3
//        ("testNew", testNew),
    ]
}
