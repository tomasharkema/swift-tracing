import SnapshotTesting
@testable import SwiftStacktrace
import XCTest

final class FunctionInfoTests: XCTestCase {

  func testFunctionInfo() throws {
    let line = String(data: Data(PackageResources.function_info_txt), encoding: .utf8)!
    let functionInfo = try FunctionInfo(line)
    assertSnapshot(of: functionInfo, as: .dump)
  }

  func testGarbage1() throws {
    let line = String(data: Data(PackageResources.function_info_garbage_1_txt), encoding: .utf8)!
    let functionInfo = try FunctionInfo(line)
    assertSnapshot(
      of: functionInfo,
      as: .dump
    )
  }

  func testGarbage2() throws {
    let line = String(data: Data(PackageResources.function_info_garbage_2_txt), encoding: .utf8)!
    let functionInfo = try FunctionInfo(line)
    assertSnapshot(
      of: functionInfo,
      as: .dump
    )
  }
}
