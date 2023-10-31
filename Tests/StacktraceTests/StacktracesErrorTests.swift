import SnapshotTesting
@testable import SwiftStacktrace
import XCTest

final class StacktracesErrorTests: XCTestCase {
  private static let error = {
    // swiftlint:disable:next force_try
    let lines = try! Bundle.module.lines
    let stack = LazyStack(lines)
    let caller = Caller(
      fileID: "SwiftStacktraceTests/SwiftStacktraceErrorTests.swift",
      line: 0,
      function: "init",
      stack: stack
    )
    let first = StacktraceError(
      underlyingError: NSError(domain: "", code: 0),
      caller: caller
    )
    return StacktraceError(
      underlyingError: first,
       caller: caller
      )
  }()

  func testStacktracesErrorDescription() {
    let string = String(describing: Self.error)
    assertSnapshot(of: string.split(separator: "\n"), as: .dump)
  }

  func testStacktracesErrorDebugDescription() {
    let string = Self.error.debugDescription
    assertSnapshot(of: string.split(separator: "\n"), as: .dump)
  }

  func testStacktracesErrorDebugLocalizedDescription() {
    let string = Self.error.localizedDescription
    assertSnapshot(of: string.split(separator: "\n"), as: .dump)
  }
}
