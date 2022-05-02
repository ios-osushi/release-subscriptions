// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ReleaseSubscriptions",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "releaseSubscriptions", targets: ["ReleaseSubscriptions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.1.1"),
        .package(url: "https://github.com/apple/swift-log", exact: "1.4.2"),
        .package(url: "https://github.com/apple/swift-markdown", branch: "main"),
        .package(url: "https://github.com/behrang/YamlSwift", exact: "3.4.4"),
    ],
    targets: [
        .executableTarget(
            name: "ReleaseSubscriptions",
            dependencies: [
                "ReleaseSubscriptionsCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
            ]),
        .target(
            name: "ReleaseSubscriptionsCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Yaml", package: "YamlSwift"),
            ]),
        .testTarget(
            name: "ReleaseSubscriptionsCoreTests",
            dependencies: ["ReleaseSubscriptionsCore"]),
    ]
)
