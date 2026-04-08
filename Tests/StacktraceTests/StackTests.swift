import Foundation
import SnapshotTesting
import Testing

@testable import SwiftStacktrace

@Suite(.snapshots(diffTool: .ksdiff))
struct StackTests {
  @Test
  func testStack() throws {
    let lines = try Bundle.module.lines
    let stack = LazyStack(lines)
    let eager = try EagerChain(stack)
    assertSnapshot(of: eager, as: .json)
  }

  @Test
  func testStackJson() throws {
    let lines = try Bundle.module.lines
    let stack = LazyStack(lines)
    let eager = try EagerChain(stack)
    let json = try eager.json
    assertSnapshot(of: json.split(separator: "\n"), as: .dump)
  }

  @Test
  func testStacktrace() throws {
    let lines = try Bundle.module.lines
    let stack = LazyStack(lines)
    assertSnapshot(of: stack.initialized.stackFormatted.split(separator: "\n"), as: .dump)
  }
}
