import XCTest
import Swogic

// TODO: include this in the library
extension Optional: EquatableAfterProjection {

    public enum Projected: EquatableToAny, Equatable {
        case none
        case some
    }

    public static var projection: (Optional) -> Projected {
        return {
            switch $0 {
            case .none:
                return .none
            case .some:
                return .some
            }
        }
    }
}

final class ProcessTests: XCTestCase {

    let step1: State<String, Int> = { (str) -> Int in
        return str.count
        } ~ "s1"
    let step2: State<Int, Double> = { (i: Int) -> Double in
        return Double(i) + 3.5
        } ~ "s2"
    let step3: State<Double, String> = { (d) -> String in
        return "Number is: " + String(d)
        } ~ "s3"
    let doubleToTrue: State<Double, Bool> = {_ in
        return true
        } ~ "t"
    let doubleToFalse: State<Double, Bool> = {_ in
        return false
        } ~ "f"

    let identity: State<Optional<Int>, Optional<Int>> = { $0 } ~ "id"
    let sum1: State<Optional<Int>, Int> = { $0.unsafelyUnwrapped + 1 } ~ "+1"

    func testProcessWithCondition() {
        let process = StateMachine([step1 ---- "Greater than 2"~{ $0 > 2 } ---> step2 ---> step3])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(process.evaluationLog, "s1 ---- {Greater than 2} ---> s2 ---> s3")

        let result2: String? = process.evaluate("ab")
        XCTAssertNil(result2)
        XCTAssertEqual(process.evaluationLog, "s1 ---- {Greater than 2}")
    }

    func testSingleBranchStatedTwice() {
        let process = StateMachine([
            step1 ---> step2 ---> step3,
            step1 ---> step2 ---> step3
            ])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 ---> s3")
    }

    func testDoubleBranch() {
        let process = StateMachine([
            step1 --->  step2 --->  step3,
            step1 ---> !step2 ---> !step3
        ])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        XCTAssertEqual(process.evaluationLog, """
        s1 ---> s2 ---> s3
           ---> s2 ---> s3
        """)
    }

    func testTwoLeafs() {

        let process = StateMachine([
            step1 ---> step2 ---> doubleToTrue,
            step1 ---> step2 ---> doubleToFalse
            ])
        let result = process.evaluate("h")
        XCTAssertEqual(result!, true)
        XCTAssertEqual(process.evaluationLog, """
        s1 ---> s2 ---> t
                   ---> f
        """)
    }

    func testTwoLeafsWithCondition() {
        let process = StateMachine([step1 ---- "Great"~{ $0 >  2 }  --->  step2 ---> step3,
                               step1 ---- "LessEq"~{ $0 <= 2 } ---> !step2 ---> step3])
        let result: String? = process.evaluate("Donkey")
        XCTAssertEqual(result!, "Number is: 9.5")
        // TODO: On the evaluation log, we cannot distinguish s2 from its copy !s2
        XCTAssertEqual(process.evaluationLog, """
        s1 ---- {Great} ---> s2 ---> s3
           ---- {LessEq}
        """)

        let result2: String? = process.evaluate("ab")
        XCTAssertEqual(result2!, "Number is: 5.5")
        XCTAssertEqual(process.evaluationLog, """
        s1 ---- {Great}
           ---- {LessEq} ---> s2 ---> s3
        """)
    }

    func testMatchCondition() {
        let process = StateMachine([step1 ---- "is 3"~{ 3 } ---> step2])

        let result1 = process.evaluate("abc")
        XCTAssertEqual(result1, 6.5)
        XCTAssertEqual(process.evaluationLog, "s1 ---- {is 3} ---> s2")

        let result2 = process.evaluate("ab")
        XCTAssertNil(result2)
        XCTAssertEqual(process.evaluationLog, "s1 ---- {is 3}")

    }

    func testMatchAfterProjectionCondition() {
        let process = StateMachine([
            identity ---- "is some?"~{ .some } ---> sum1
        ])

        let result1 = process.evaluate(2)
        XCTAssertEqual(result1, 3)
        XCTAssertEqual(process.evaluationLog, "id ---- {is some?} ---> +1")

        let result2 = process.evaluate(nil)
        XCTAssertEqual(result2, nil)
        XCTAssertEqual(process.evaluationLog, "id ---- {is some?}")
    }

    func testSubProcess() {
        let subProcess = "subprocess" ~ StateMachine([step2 ---> step3])
        let process = "process" ~ StateMachine([step1 ---> subProcess ---> !step1])
        let result: Int? = process.evaluate("Donkey")

        XCTAssertEqual(result, 14)
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 ---> s3 ---> s1")

        let process2 = "process2" ~ StateMachine([step1 ---> subProcess])
        let result2: String? = process2.evaluate("Donkey")

        XCTAssertEqual(result2, "Number is: 9.5")
        XCTAssertEqual(process2.evaluationLog, "s1 ---> s2 ---> s3")
    }

    func testSubProcess2() {
        let subProcess = "subprocess" ~ StateMachine([step2 ---> step3])
        let process = "process" ~ StateMachine([
            step1 ---> subProcess ---> !step1,
            step1 ---> subProcess ---> !step1,
        ])
        let result: Int? = process.evaluate("Donkey")

        XCTAssertEqual(result, 14)
        XCTAssertEqual(process.evaluationLog, """
        s1 ---> s2 ---> s3 ---> s1
                           ---> s1
        """)

        let process2 = "process2" ~ StateMachine([
            step1 ---> subProcess,
            step1 ---> !subProcess
        ])
        let result2: String? = process2.evaluate("Donkey")

        XCTAssertEqual(result2, "Number is: 9.5")
        XCTAssertEqual(process2.evaluationLog, """
        s1 ---> s2 ---> s3
           ---> s2 ---> s3
        """)
    }

    var stepVoid1: State<(), Int> = { () -> Int in
        return 1
    } ~ "s1"
    var stepVoid2: State<Int, ()> = { (i) -> () in
        return ()
    } ~ "s2"
    var stepVoid3: State<(), ()> = { () -> () in
        return ()
    } ~ "s3"

    func testVoidProcess() {
        let process = Swogic.StateMachine<(), ()>([
            stepVoid1 ---> stepVoid2 ---- { _ in true } ---> stepVoid3
        ])
        _ = process.evaluate(())
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 ---- {} ---> s3")
    }
}
