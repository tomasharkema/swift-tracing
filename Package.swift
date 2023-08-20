// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

var dependencies = [Package.Dependency]()
var plugins = [Target.PluginUsage]()

 #if !os(Linux)
 if ProcessInfo.processInfo.environment["RESOLVE_COMMAND_PLUGINS"] != nil {
    dependencies.append(contentsOf: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.52.2"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.51.12"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.3.0"),
    ])
    plugins.append(contentsOf: [
        .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
    ])
 }
 #endif

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
            name: "SwiftTracingTestHelpers",
            targets: ["SwiftTracingTestHelpers"]
        ),
        .library(
            name: "SwiftThreading",
            targets: ["SwiftThreading"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/oozoofrog/SwiftDemangle.git", from: "5.5.8"),
    ] + dependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftTracing",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
            ],
            plugins: plugins
        ),
        .target(
            name: "SwiftTaskToolbox",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
            ],
            plugins: plugins
        ),
        .target(
            name: "SwiftTracingTestHelpers",
            dependencies: ["SwiftTaskToolbox"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
            ],
            plugins: plugins
        ),
        .target(
            name: "SwiftThreading",
            dependencies: [
                .product(name: "SwiftDemangleFramework", package: "SwiftDemangle"),
                // .product(name: "SwiftDemangle", package: "SwiftDemangle"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
            ],
            plugins: plugins
        ),
        .binaryTarget(
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.52.1/swiftformat.artifactbundle.zip",
            checksum: "ece546c839869004a412ba705839301cdbc22dde182bc09b159ad80b24967357"
        ),
        .testTarget(
            name: "SwiftTracingTests",
            dependencies: ["SwiftTracing", "SwiftTaskToolbox"]
        ),
    ]
)
