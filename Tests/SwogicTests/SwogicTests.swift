import XCTest
@testable import Swogic

final class SwogicTests: XCTestCase {

    func testOperationAndResultComposition() {
        let action1 = Action<String>()
        let preChain1 = action1 ---| "abc" as ActionPreChain

        let action2 = Action<Int>()
        let actionChain1 = preChain1 |---> action2 as ActionChain<Int>

        let preChain2 = actionChain1 ---| 3 as ActionPreChain

        let action3 = Action<Bool>()
        _ = preChain2 |---> action3 as ActionChain<Bool>


        _ = action1 ---| "abc" |---> action2 ---| 3 |---> action3

        _ = Flow(
            action1 ---| "abc" |---> action2 ---| 3 |---> action3,
            action1 ---| "zzz" |---> action3
        )
    }


    static var allTests = [
        ("testOperationAndResultComposition", testOperationAndResultComposition),
    ]
}
