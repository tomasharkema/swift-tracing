import SnapshotTesting
@testable import SwiftStacktrace
import XCTest

final class CallerTests: XCTestCase {

  func testCaller() throws {
    let lines = try PackageResources.lines
    let caller = LazyCaller(lines)
    let eager = try EagerChain(caller)
    assertSnapshot(of: eager, as: .json)
  }

  func testCallerJson() throws {
    let lines = try PackageResources.lines
    let caller = LazyCaller(lines)
    let eager = try EagerChain(caller)
    let json = try eager.json
    assertSnapshot(of: json)
  }
}
