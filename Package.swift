// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mappo",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/async-kit.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0"),
        .package(url: "https://github.com/rexmas/JSONValue.git", from: "7.0.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.3"),
        .package(url: "https://github.com/DiscordBM/DiscordBM.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MappoCore",
            dependencies: [
            .product(name: "AsyncKit", package: "async-kit"),
            .product(name: "Collections", package: "swift-collections"),
            .product(name: "Algorithms", package: "swift-algorithms")]
        ),
        .executableTarget(
            name: "Mappo",
            dependencies: ["MappoCore", .product(name: "DiscordBM", package: "DiscordBM"), .product(name: "AsyncKit", package: "async-kit")]),
        // .executableTarget(
        //     name: "Mapptrix",
        //     dependencies: ["MappoCore", .product(name: "SQLite", package: "SQLite.swift"), .product(name: "JSONValueRX", package: "JSONValue"), .product(name: "AsyncHTTPClient", package: "async-http-client"), .product(name: "AsyncKit", package: "async-kit")]),
        .testTarget(
            name: "MappoTests",
            dependencies: ["Mappo"]),
    ]
)
