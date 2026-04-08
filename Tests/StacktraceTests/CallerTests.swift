import Foundation
import SnapshotTesting
import Testing

@testable import SwiftStacktrace

@Suite(.snapshots(diffTool: .ksdiff))
struct CallerTests {
  @Test
  func testCaller() throws {
    let lines = try Bundle.module.lines
    let caller = LazyCaller(lines)
    let eager = try EagerChain(caller)
    assertSnapshot(of: eager, as: .json)
  }

  @Test
  func testCallerJson() throws {
    let lines = try Bundle.module.lines
    let caller = LazyCaller(lines)
    let eager = try EagerChain(caller)
    let json = try eager.json
    assertSnapshot(of: json.split(separator: "\n"), as: .dump)
  }
}
