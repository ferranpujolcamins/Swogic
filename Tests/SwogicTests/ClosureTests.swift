import XCTest
import Swogic

final class ClosureTests: XCTestCase {

    func testEquivalence() {
        let closure: (Int) -> Bool = { i in i > 0 }
        let typeErasedClosure = eraseType(closure)

        XCTAssertEqual(typeErasedClosure(3) as? Bool ?? false, true)
        XCTAssertEqual(typeErasedClosure(-3) as? Bool ?? true, false)
    }

    func testComposability() {
        let closure1: (String) -> (Int) = { s in s.count }
        let closure2: (Int) -> (Int) = { i in i-4 }
        let typeErasedC1 = eraseType(closure1)
        let typeErasedC2 = eraseType(closure2)

        let result = typeErasedC2(typeErasedC1("four"))

        XCTAssertEqual(result as? Int ?? -1, 0)
    }


    static var allTests = [
        ("testEquivalence", testEquivalence),
        ("testComposability", testComposability),
    ]
}
