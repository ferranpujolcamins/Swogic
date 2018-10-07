import XCTest
import Swogic

final class CollectionTests: XCTestCase {

    func testEmptyCollection() {
        let collection: [Int] = []
        let uniqueElement = collection.uniqueElement
        XCTAssertNil(uniqueElement, "uniqueElement of an empty collection should be nil")
    }

    func testHeterogeneousCollection1() {
        let collection = ["Hello", "Bye"]
        let uniqueElement = collection.uniqueElement
        XCTAssertNil(uniqueElement, "uniqueElement of an heterogeneous collection should be nil")
    }

    func testHeterogeneousCollection2() {
        let collection = ["A", "A", "B"]
        let uniqueElement = collection.uniqueElement
        XCTAssertNil(uniqueElement, "uniqueElement of an heterogeneous collection should be nil")
    }

    func testSingleElementCollection() {
        let collection = [true]
        let uniqueElement = collection.uniqueElement
        XCTAssertEqual(uniqueElement, .some(true),"uniqueElement of a single element collection should return the element")
    }

    func testhomogeneousCollection() {
        let collection = [1, 1, 1, 1]
        let uniqueElement = collection.uniqueElement
        XCTAssertEqual(uniqueElement, .some(1),"uniqueElement of an homogeneous collection should return the unique element")
    }
}
