import SnapshotTesting
@testable import SwiftStacktrace
import XCTest

final class FunctionInfoTests: XCTestCase {
  func testFunctionInfo() throws {
    let url = Bundle.module.url(
      forResource: "function_info",
      withExtension: "txt",
      subdirectory: "TestResources"
    )!
    let data = try Data(contentsOf: url)
    let line = String(data: data, encoding: .utf8)!
    let functionInfo = try FunctionInfo(line)
    assertSnapshot(of: functionInfo, as: .dump)
  }

  func testGarbage1() throws {
    let url = Bundle.module.url(
      forResource: "function_info_garbage_1",
      withExtension: "txt",
      subdirectory: "TestResources"
    )!
    let data = try Data(contentsOf: url)
    let line = String(data: data, encoding: .utf8)!
    let functionInfo = try FunctionInfo(line)
    assertSnapshot(
      of: functionInfo,
      as: .dump
    )
  }

  func testGarbage2() throws {
    let url = Bundle.module.url(
      forResource: "function_info_garbage_2",
      withExtension: "txt",
      subdirectory: "TestResources"
    )!
    let data = try Data(contentsOf: url)
    let line = String(data: data, encoding: .utf8)!
    let functionInfo = try FunctionInfo(line)
    assertSnapshot(
      of: functionInfo,
      as: .dump
    )
  }
}
