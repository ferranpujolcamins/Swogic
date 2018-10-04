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

    func testMultipleChainFlow() {
        let a = =>step1 --- { $0 < 2 } ---> step2 ---> step3 --- { $0.count < 4 } ---> step1
    }

    static var allTests = [ 3
//        ("testNew", testNew),
    ]
}
