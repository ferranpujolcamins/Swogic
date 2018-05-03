import XCTest
@testable import Swogic

final class SwogicTests: XCTestCase {


    func testNew() {

        // Actions can be values or class! If value, we add new, if class, we try to match??
        let action1 = Action<String, Int>()
        let action2 = Action<Int, Double>()
        let action3 = Action<Double, String>()

        action1 ---> action2 ---> action3

        *action1 --- { $0 < 2 } ---> *action2

    }






    func testOperationAndResultComposition() {
        let action1 = Action<String> { () -> String in
            print("I return 'abc'")
            return "abc"
        }
        let preChain1 = action1 ---| "abc" as ActionPreChain

        let action2 = Action<Int> { () -> Int in
            print("I return 3")
            return 3
        }
        let actionChain1 = preChain1 |---> action2 as ActionChain<Int>

        let preChain2 = actionChain1 ---| 3 as ActionPreChain

        let action3 = Action<Bool> { () -> Bool in
            print("I return false")
            return false
        }
        _ = preChain2 |---> action3 as ActionChain<Bool>


        _ = action1 ---| "abc" |---> action2 ---| 3 |---> action3

        _ = Flow(
            action1 ---| "abc" |---> action2 ---| 3 |---> action3,
            action1 ---| "zzz" |---> action3
        )

        _ = Action {
            print("I return nothing")
        } as Action<VoidResult>

        let voidAction = Action {
            print("I return nothing")
        }

        _ = action1 ---| "abc" |---> action2 ---| 3 |---> voidAction


        _ = Flow(
            Action{ return true } ---| true |---> Action{ print("4") }
        )

    }


    static var allTests = [
        ("testOperationAndResultComposition", testOperationAndResultComposition),
    ]
}
