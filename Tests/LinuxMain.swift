import XCTest

import SwogicTests
import DSLTests

var tests = [XCTestCaseEntry]()
tests += SwogicTests.allTests()
tests += DSLTests.allTests()
XCTMain(tests)
