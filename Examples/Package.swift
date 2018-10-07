// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Examples",
    dependencies: [
         .package(path: "../Swogic"),
    ],
    targets: [
        .target(
            name: "Examples",
            dependencies: ["Swogic"]),
        .testTarget(
            name: "ExamplesTests",
            dependencies: ["Examples"]),
    ]
)
