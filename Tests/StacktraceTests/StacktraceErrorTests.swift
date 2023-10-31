import SnapshotTesting
@testable import SwiftStacktrace
import XCTest

final class StacktraceErrorTests: XCTestCase {
  private static let error = {
    // swiftlint:disable:next force_try
    let lines = try! PackageResources.lines
    let stack = LazyStack(lines)
    let caller = Caller(
      fileID: "SwiftStacktraceTests/SwiftStacktraceErrorTests.swift",
      line: 0,
      function: "init",
      stack: stack
    )
    return StacktraceError(
      underlyingError: NSError(domain: "", code: 0),
      caller: caller
    )
  }()

  func testStacktraceErrorDescription() {
    let string = String(describing: Self.error)
    assertSnapshot(of: string)
  }

  func testStacktraceErrorDebugDescription() {
    let string = Self.error.debugDescription
    assertSnapshot(of: string)
  }

  func testStacktraceErrorDebugLocalizedDescription() {
    let string = Self.error.localizedDescription
    assertSnapshot(of: string)
  }
}
