// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTracing",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftTracing",
            targets: ["SwiftTracing"]
        ),
        .library(
            name: "SwiftTaskToolbox",
            targets: ["SwiftTaskToolbox"]
        ),
        .library(
            name: "TestHelpers",
            targets: ["TestHelpers"]
        ),
        .library(
            name: "SwiftThreading",
            targets: ["SwiftThreading"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/oozoofrog/SwiftDemangle.git", from: "5.5.8"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.52.1"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.52.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftTracing",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
            ]
        ),
        .target(
            name: "SwiftTaskToolbox",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
            ]
        ),
        .target(
            name: "TestHelpers",
            dependencies: ["SwiftTaskToolbox"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
            ]
        ),
        .target(
            name: "SwiftThreading",
            dependencies: [
                .product(name: "SwiftDemangleFramework", package: "SwiftDemangle"),
                // .product(name: "SwiftDemangle", package: "SwiftDemangle"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
            ]
        ),
        .binaryTarget(
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.52.1/swiftformat.artifactbundle.zip",
            checksum: "ece546c839869004a412ba705839301cdbc22dde182bc09b159ad80b24967357"
        ),
        // .testTarget(
        //     name: "SwiftTracingTests",
        //     dependencies: ["SwiftTracing"]),
    ]
)
