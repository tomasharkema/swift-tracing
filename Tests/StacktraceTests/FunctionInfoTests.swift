import Foundation
import SnapshotTesting
import Testing

@testable import SwiftStacktrace

@Suite(.snapshots(diffTool: .ksdiff))
struct FunctionInfoTests {
  @Test(arguments: [
    "function_info",
    "function_info_garbage_1",
    "function_info_garbage_2",
  ])
  func testFunctionInfo(variant: String) throws {
    let url = Bundle.module.url(
      forResource: variant,
      withExtension: "txt"
    )!
    let data = try Data(contentsOf: url)
    let line = String(data: data, encoding: .utf8)!
    let functionInfo = try FunctionInfo(line)
    assertSnapshot(of: functionInfo, as: .dump, named: variant)
  }
}
