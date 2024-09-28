// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ReleaseSubscriptions",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "releaseSubscriptions", targets: ["ReleaseSubscriptions"]),
        .executable(name: "releaseSummarizer", targets: ["ReleaseSummarizer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.5.0"),
        .package(url: "https://github.com/apple/swift-log", exact: "1.6.1"),
        .package(url: "https://github.com/swiftlang/swift-markdown", exact: "0.5.0"),
        .package(url: "https://github.com/behrang/YamlSwift", exact: "3.4.4"),
        .package(url: "https://github.com/google-gemini/generative-ai-swift.git", exact: "0.5.6"),
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
        .executableTarget(
            name: "ReleaseSummarizer",
            dependencies: [
                "ReleaseSummarizerCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "ReleaseSummarizerCore",
            dependencies: [
                "ReleaseSubscriptionsCore",
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "ReleaseSubscriptionsCoreTests",
            dependencies: ["ReleaseSubscriptionsCore"]),
    ]
)
