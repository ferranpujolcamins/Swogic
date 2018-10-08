import XCTest
import Swogic

final class ProcessTests: XCTestCase {

    let step1: Step<String, Int> = { (str) -> Int in
        return str.count
        } ~ "s1"
    let step2: Step<Int, Double> = { (i: Int) -> Double in
        return Double(i) + 3.5
        } ~ "s2"
    let step3: Step<Double, String> = { (d) -> String in
        return "Number is: " + String(d)
        } ~ "s3"
    let doubleToTrue: Step<Double, Bool> = {_ in
        return true
        } ~ "t"
    let doubleToFalse: Step<Double, Bool> = {_ in
        return false
        } ~ "f"

    func testProcessWithCondition() {
        let process = Process([step1 --- { $0 > 2 }~"Greater than 2" ---> step2 ---> step3])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(process.evaluationLog, "s1 --- {Greater than 2} ---> s2 ---> s3")

        let result2: String? = process.evaluate("ab")
        XCTAssertNil(result2)
        XCTAssertEqual(process.evaluationLog, "s1 --- {Greater than 2}")
    }

    func testSingleBranchStatedTwice() {
        let process = Process([
            step1 ---> step2 ---> step3,
            step1 ---> step2 ---> step3
            ])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 ---> s3")
    }

    func testDoubleBranch() {
        let process = Process([
            step1 ---> step2 ---> step3,
            step1 ---> !step2 ---> !step3
            ])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        // TODO: this log is not accurate because it does not take into account the stack structure
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 ---> s3 ---> s2 ---> s3")
    }

    func testTwoLeafs() {

        let process = Process([
            step1 ---> step2 ---> doubleToTrue,
            step1 ---> step2 ---> doubleToFalse
            ])
        let result = process.evaluate("h")
        XCTAssertEqual(result!, true)
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 ---> t ---> f")
    }

    func testTwoLeafsWithCondition() {
        let process = Process([step1 --- { $0 > 2 }~"Great" ---> step2 ---> step3,
                                      step1 --- { $0 <= 2 }~"LessEq" ---> !step2 ---> step3])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        // TODO: On the evaluation log, we cannot distinguish s2 from its copy !s2
        XCTAssertEqual(process.evaluationLog, "s1 --- {Great} ---> s2 ---> s3 --- {LessEq}")

        let result2: String? = process.evaluate("ab")
        XCTAssertEqual(result2!, "Number is: 5.5")
        XCTAssertEqual(process.evaluationLog, "s1 --- {Great} --- {LessEq} ---> s2 ---> s3")
    }

    func testMatchCondition() {
        let process = Process([step1 --- { 3 }~"is 3" ---> step2])

        let result1 = process.evaluate("abc")
        XCTAssertEqual(result1, 6.5)
        XCTAssertEqual(process.evaluationLog, "s1 --- {is 3} ---> s2")

        let result2 = process.evaluate("ab")
        XCTAssertNil(result2)
        XCTAssertEqual(process.evaluationLog, "s1 --- {is 3}")

    }

    var stepVoid1: Step<(), Int> = { () -> Int in
        return 1
    } ~ "s1"
    var stepVoid2: Step<Int, ()> = { (i) -> () in
        return ()
    } ~ "s2"
    var stepVoid3: Step<(), ()> = { () -> () in
        return ()
    } ~ "s3"

    func testVoidProcess() {
        let process = Swogic.Process<(), ()>([
            stepVoid1 ---> stepVoid2 --- { _ in true } ---> stepVoid3
        ])
        _ = process.evaluate(())
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 --- {} ---> s3")
    }
}
