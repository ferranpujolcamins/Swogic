// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swogic",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Swogic",
            targets: ["Swogic"]),
    ],
    dependencies: [
//        .package(url:"https://github.com/davecom/SwiftGraph", .exact("2.0.0")),
        .package(url:"/Users/ferranpujolcamins/development/SwiftGraph", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Swogic",
            dependencies: ["SwiftGraph"]),
        .testTarget(
            name: "SwogicTests",
            dependencies: ["Swogic"])
    ]
)
