import SnapshotTesting
@testable import SwiftStacktrace
import XCTest

final class StackTests: XCTestCase {
  override class func setUp() {
    super.setUp()
    // isRecording = true
  }

  func testStack() throws {
    let lines = try PackageResources.lines
    let stack = LazyStack(lines)
    let eager = try EagerChain(stack)
    assertSnapshot(of: eager, as: .json)
  }

  func testStackJson() throws {
    let lines = try PackageResources.lines
    let stack = LazyStack(lines)
    let eager = try EagerChain(stack)
    let json = try eager.json
    assertSnapshot(of: json, as: .dump)
  }

  func testStacktrace() throws {
    let lines = try PackageResources.lines
    let stack = LazyStack(lines)
    assertSnapshot(of: stack.initialized.stackFormatted, as: .dump)
  }
}
