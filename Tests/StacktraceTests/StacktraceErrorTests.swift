import Foundation
import SnapshotTesting
import Testing

@testable import SwiftStacktrace

@Suite(.snapshots(diffTool: .ksdiff))
struct StacktraceErrorTests {

  private func testError() throws -> StacktraceError {
    let lines = try Bundle.module.lines
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
  }

  @Test
  func testStacktraceErrorDescription() throws {
    let string = String(describing: try testError())
    assertSnapshot(of: string.split(separator: "\n"), as: .dump)
  }

  @Test
  func testStacktraceErrorDebugDescription() throws {
    let string = try testError().debugDescription
    assertSnapshot(of: string.split(separator: "\n"), as: .dump)
  }

  @Test
  func testStacktraceErrorDebugLocalizedDescription() throws {
    let string = try testError().localizedDescription
    assertSnapshot(of: string.split(separator: "\n"), as: .dump)
  }
}
