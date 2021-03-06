import XCTest

extension ClosureTests {
    static let __allTests = [
        ("testComposability", testComposability),
        ("testEquivalence", testEquivalence),
    ]
}

extension CollectionTests {
    static let __allTests = [
        ("testEmptyCollection", testEmptyCollection),
        ("testHeterogeneousCollection1", testHeterogeneousCollection1),
        ("testHeterogeneousCollection2", testHeterogeneousCollection2),
        ("testhomogeneousCollection", testhomogeneousCollection),
        ("testSingleElementCollection", testSingleElementCollection),
    ]
}

extension ProcessTests {
    static let __allTests = [
        ("testDoubleBranch", testDoubleBranch),
        ("testProcessWithCondition", testProcessWithCondition),
        ("testSingleBranchStatedTwice", testSingleBranchStatedTwice),
        ("testTwoLeafs", testTwoLeafs),
        ("testTwoLeafsWithCondition", testTwoLeafsWithCondition),
        ("testVoidProcess", testVoidProcess),
    ]
}

extension StepChainSequenceTests {
    static let __allTests = [
        ("testIterator", testIterator),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ClosureTests.__allTests),
        testCase(CollectionTests.__allTests),
        testCase(ProcessTests.__allTests),
        testCase(StepChainSequenceTests.__allTests),
    ]
}
#endif
