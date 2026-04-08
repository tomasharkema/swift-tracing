// swift-tools-version: 6.3

import Foundation
import PackageDescription

let package = Package(
  name: "SwiftTracing",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(
      name: "SwiftTracing",
      targets: ["SwiftTracing"]
    ),
    .library(
      name: "SwiftTaskToolbox",
      targets: ["SwiftTaskToolbox"]
    ),
    .library(
      name: "SwiftStacktrace",
      targets: ["SwiftStacktrace"]
    ),
    .library(
      name: "StringsBuilder",
      targets: ["StringsBuilder"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax", "600.0.0"..<"603.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.2"),
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.1"),
  ],
  targets: [
    .target(
      name: "SwiftTracing",
      dependencies: [
        "SwiftStacktrace"
      ]
    ),
    .target(
      name: "SwiftTaskToolbox"
    ),
    .target(
      name: "SwiftStacktrace",
      dependencies: [
        "StringsBuilder",
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "StringsBuilder",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms")
      ]
    ),
    .executableTarget(
      name: "TestRunner",
      dependencies: [
        "SwiftTracing"
      ]
    ),
    .testTarget(
      name: "TracingTests",
      dependencies: [
        "SwiftTracing"
      ]
    ),
    .testTarget(
      name: "StacktraceTests",
      dependencies: [
        "SwiftStacktrace",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"],
      resources: [
        .process("TestResources")
      ]
    ),
  ]
)

#if !os(Linux)
  //    package.dependencies.append(contentsOf: [
  //      .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.60.1")
  //    ])

  package.dependencies.append(
    .package(
      url: "https://github.com/SimplyDanny/SwiftLintPlugins",
      from: "0.62.2"
    ))

  for target in package.targets {
    var plugin = target.plugins ?? []
    plugin.append(.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"))
    target.plugins = plugin
  }

#endif

package.dependencies.append(
  .package(
    url: "https://github.com/apple/swift-docc-plugin",
    from: "1.4.5"
  ))
