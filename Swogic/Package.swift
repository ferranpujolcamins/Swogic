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
      .package(url:"https://github.com/davecom/SwiftGraph", .branch("master"))
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
