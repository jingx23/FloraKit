// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "FloraKit",
    products: [
        .library(
            name: "FloraKit",
            targets: ["FloraKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FloraKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "FloraKitTests",
            dependencies: ["FloraKit"],
            path: "Tests"
        ),
    ]
)
