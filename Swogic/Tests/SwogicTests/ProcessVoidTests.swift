import XCTest
import Swogic

final class ProcessTests: XCTestCase {
    var step1: Step<(), Int> = { () -> Int in
        return 1
    } ~ "s1"
    var step2: Step<Int, ()> = { (i) -> () in
        return ()
    } ~ "s2"
    var step3: Step<(), ()> = { () -> () in
        return ()
    } ~ "s3"

    func testVoidProcess() {
        let process = Swogic.Process<(), ()>([
            step1 ---> step2 --- { _ in true } ---> step3
        ])
        _ = process.evaluate(())
        XCTAssertEqual(process.evaluationLog, "s1 ---> s2 --- {} ---> s3")
    }
}
