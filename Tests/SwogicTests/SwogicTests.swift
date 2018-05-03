import XCTest
@testable import Swogic

final class SwogicTests: XCTestCase {


    func testNew() {

        // Actions can be values or class! If value, we add new, if class, we try to match??
        let action1 = Step<String, Int>()
        let action2 = Step<Int, Double>()
        let action3 = Step<Double, String>()

        action1 ---> action2 ---> action3

        *action1 --- { $0 < 2 } ---> action2 ---> *action3

    }


    static var allTests = [
        ("testNew", testNew),
    ]
}
