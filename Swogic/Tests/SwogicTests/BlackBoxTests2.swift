import XCTest
@testable import Swogic

// we use this tests, among other things, to test that the access levels set are correct
final class SwogicTests: XCTestCase {

    var state: [String] = []

    var step1: Step<String, Int> = Step({_ in 0})
    var step2: Step<Int, Double> = Step({_ in 0})
    var step3: Step<Double, String> = Step({_ in ""})
    var doubleToTrue: Step<Double, Bool> = Step({_ in true})
    var doubleToFalse: Step<Double, Bool> = Step({_ in false})

    override func setUp() {
        step1 = Step<String, Int> { (str) -> Int in
            self.state.append("s1")
            return str.count
        }
        step2 = Step<Int, Double> { (i: Int) -> Double in
            self.state.append("s2")
            return Double(i) + 3.5
        }
        step3 = Step<Double, String> { (d) -> String in
            self.state.append("s3")
            return "Number is: " + String(d)
        }
        doubleToTrue = Step<Double, Bool>({_ in
            self.state.append("true")
            return true
        })
        doubleToFalse = Step<Double, Bool>({_ in
            self.state.append("false")
            return false
        })
        step1.name = "step1"
        step2.name = "step2"
        step3.name = "step3"
        doubleToTrue.name = "true"
        doubleToFalse.name = "false"
        state = []
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

    func testProcessWithCondition() {
        let process = Swogic.Process([step1 --- { $0 > 2 }~"Greater than 2" ---> step2 ---> step3])
        let result: String? = process.evaluate("Ferran")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(state, ["s1", "s2", "s3"])

        state = []
        let result2: String? = process.evaluate("ab")
        XCTAssertNil(result2)
        XCTAssertEqual(state, ["s1"])
    }

    func testSingleBranchStatedTwice() {
        let process = Swogic.Process([
            step1 ---> step2 ---> step3,
            step1 ---> step2 ---> step3
        ])
        let result: String? = process.evaluate("Ferran")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(state, ["s1", "s2", "s3"])
    }

    func testDoubleBranch() {
        let process = Swogic.Process([
            step1 ---> step2 ---> step3,
            step1 ---> !step2 ---> !step3
            ])
        let result: String? = process.evaluate("Ferran")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(state, ["s1", "s2", "s3", "s2", "s3"])
    }

    func testTwoLeafs() {

        let process = Swogic.Process([
            step1 ---> step2 ---> doubleToTrue,
            step1 ---> step2 ---> doubleToFalse
        ])
        let result = process.evaluate("h")
        XCTAssertEqual(result!, true)
        XCTAssertEqual(state, ["s1", "s2", "true", "false"])
    }

    func testFlow2() {
//        let process = Swogic.Process([step1 --- { $0 > 2 } ---> step2 ---> step3,
//                                       step1 --- { $0 < 2 } ---> !step2 ---> step3])
//        let result: String? = process.evaluate("Ferran")
//        XCTAssertEqual(result!, "Number is: 9.5")
//
//        let result2: String? = process.evaluate("ab")
//        XCTAssertEqual(result2!, "Number is: 5.5")
    }
}
