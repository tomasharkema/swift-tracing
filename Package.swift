// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let isXcode = ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
let isSubDependency: () -> Bool = {
    let context = ProcessInfo.processInfo.arguments.drop {
        $0 != "-context"
    }.dropFirst(1).first
    guard let context else {
        return false
    }
    guard let json = (try? JSONSerialization.jsonObject(with: context.data(using: .utf8) ?? Data())) as? [String: Any] else {
        return false
    }
    guard let packageDirectory = json["packageDirectory"] as? String else {
        return false
    }
    return packageDirectory.contains(".build") || packageDirectory.contains("DerivedData")
}

var dependencies = [Package.Dependency]()
var plugins = [Target.PluginUsage]()

if isXcode && !isSubDependency() {
#if !os(Linux)
    dependencies.append(contentsOf: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.51.12"),
    ])

    dependencies.append(.package(url: "https://github.com/realm/SwiftLint.git", from: "0.52.2"))
    plugins.append(contentsOf: [
        .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
    ])
#endif
}

if !isSubDependency() {
    dependencies.append(contentsOf: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.3.0"),
    ])
}

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
        .executable(name: "TestApp", targets: ["TestApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/oozoofrog/SwiftDemangle.git", from: "5.5.8"),
    ] + dependencies,
    targets: [
        .target(
            name: "SwiftTracing",
            dependencies: [
                .product(name: "SwiftDemangleFramework", package: "SwiftDemangle"),
            ],
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
        .executableTarget(
            name: "TestApp",
            dependencies: [
                "SwiftTracing",
            ]
        ),
        .testTarget(
            name: "SwiftTracingTests",
            dependencies: ["SwiftTracing", "SwiftTaskToolbox"]
        ),
        // .binaryTarget(
        //     name: "swiftformat",
        //     url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.52.1/swiftformat.artifactbundle.zip",
        //     checksum: "ece546c839869004a412ba705839301cdbc22dde182bc09b159ad80b24967357"
        // ),
        // .binaryTarget(
        //     name: "SwiftLintBinary",
        //     url: "https://github.com/realm/SwiftLint/releases/download/0.52.4/SwiftLintBinary-macos.artifactbundle.zip",
        //     checksum: "8a8095e6235a07d00f34a9e500e7568b359f6f66a249f36d12cd846017a8c6f5"
        // ),
    ]
)
