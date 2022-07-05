// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mappo",
    dependencies: [
        .package(url: "https://github.com/SketchMaster2001/Swiftcord", branch: "master"),
        .package(url: "https://github.com/vapor/async-kit.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Mappo",
            dependencies: ["Swiftcord", .product(name: "AsyncKit", package: "async-kit")]),
        .testTarget(
            name: "MappoTests",
            dependencies: ["Mappo"]),
    ]
)
