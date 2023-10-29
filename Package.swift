// swift-tools-version: 5.9

import Foundation
import PackageDescription

let package = Package(
  name: "SwiftTracing",
  platforms: [.iOS(.v14), .macOS(.v12)],
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
      name: "SwiftTracingTestHelpers",
      targets: ["SwiftTracingTestHelpers"]
    ),
    .library(name: "SwiftStacktrace", targets: ["SwiftStacktrace"]),
    .library(name: "SwiftStacktraceDynamic", type: .dynamic, targets: ["SwiftStacktrace"]),
    .executable(name: "TestApp", targets: ["TestApp"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.12.0"),
  ],
  targets: [
    .target(
      name: "SwiftTracing",
      dependencies: [
        "SwiftStacktrace",
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
        .define("RELEASE", .when(configuration: .release)),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableExperimentalFeature("NestedProtocols"),
        .enableExperimentalFeature("AccessLevelOnImport"),
      ]
    ),
    .target(
      name: "SwiftTaskToolbox",
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
        .define("RELEASE", .when(configuration: .release)),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableExperimentalFeature("NestedProtocols"),
        .enableExperimentalFeature("AccessLevelOnImport"),
      ]
    ),
    .target(
      name: "SwiftTracingTestHelpers",
      dependencies: ["SwiftTaskToolbox"],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
        .define("RELEASE", .when(configuration: .release)),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableExperimentalFeature("NestedProtocols"),
        .enableExperimentalFeature("AccessLevelOnImport"),
      ]
    ),
    .target(
      name: "SwiftStacktrace",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
        .define("RELEASE", .when(configuration: .release)),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableExperimentalFeature("NestedProtocols"),
        .enableExperimentalFeature("AccessLevelOnImport"),
      ]
    ),
    .executableTarget(
      name: "TestApp",
      dependencies: [
        "SwiftTracing",
      ],
      swiftSettings: [
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableExperimentalFeature("NestedProtocols"),
        .enableExperimentalFeature("AccessLevelOnImport"),
      ]
    ),
    .testTarget(
      name: "SwiftTracingTests",
      dependencies: ["SwiftTracing", "SwiftTaskToolbox"]
    ),
    .testTarget(
      name: "SwiftStacktraceTests",
      dependencies: [
        "SwiftStacktrace",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),
  ]
)

let isXcode = ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
let isSubDependency: () -> Bool = {
  let context = ProcessInfo.processInfo.arguments.drop {
    $0 != "-context"
  }.dropFirst(1).first
  guard let context else {
    return false
  }
  guard let json = (try? JSONSerialization
    .jsonObject(with: context.data(using: .utf8) ?? Data())) as? [String: Any]
  else {
    return false
  }
  guard let packageDirectory = json["packageDirectory"] as? String else {
    return false
  }
  return packageDirectory.contains(".build") || packageDirectory
    .contains("DerivedData") || packageDirectory == "/"
}

if isXcode, !isSubDependency() {
#if !os(Linux)
  package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.51.12"),
  ])

  package.dependencies.append(.package(
    url: "https://github.com/realm/SwiftLint.git",
    from: "0.52.2"
  ))

  for target in package.targets {
    var plugin = target.plugins ?? []
    plugin.append(.plugin(name: "SwiftLintPlugin", package: "SwiftLint"))
    target.plugins = plugin
  }

#endif
}

if !isSubDependency() {
  package.dependencies.append(.package(
    url: "https://github.com/apple/swift-docc-plugin.git",
    from: "1.3.0"
  ))
}
