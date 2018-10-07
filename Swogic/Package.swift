// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swogic",
    products: [
        .library(
            name: "Swogic",
            targets: ["Swogic"]),
    ],
    dependencies: [
//        .package(url:"https://github.com/davecom/SwiftGraph", .exact("2.0.0")),
        .package(url:"https://github.com/ferranpujolcamins/SwiftGraph", .branch("master")),
    ],
    targets: [
        .target(
            name: "Swogic",
            dependencies: ["SwiftGraph"]),
        .testTarget(
            name: "SwogicTests",
            dependencies: ["Swogic"])
    ]
)
