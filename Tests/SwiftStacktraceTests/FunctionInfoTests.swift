import SnapshotTesting
@testable import SwiftStacktrace
import XCTest

// swiftlint:disable line_length

final class FunctionInfoTests: XCTestCase {
  func testFunctionInfo() throws {
    let functionInfo =
      try FunctionInfo(
        "default argument 3 of SwiftStacktrace.Caller.init(_: Swift.String, _: Swift.UInt, _: Swift.String, stack: any Swift.Sequence<Self.Swift.Sequence.Element == Swift.String>) -> SwiftStacktrace.Caller"
      )
    assertSnapshot(of: functionInfo, as: .dump)
  }

  func testGarbage() throws {
    try assertSnapshot(
      of: FunctionInfo(
        "(6) suspend resume partial function for PlexApi.Requestor.request<A where A: Swift.Decodable>(url: Foundation.URL, _: A.Type, requestUUID: Swift.Optional<Foundation.UUID>, method: Swift.String, queryItems: Swift.Optional<Swift.Array<Foundation.URLQueryItem>>, sendDefaultQueries: Swift.Bool, timeout: Swift.Optional<Swift.Duration>, invalidateAfterError: Swift.Bool, useCache: Swift.Bool, onlyCached: Swift.Bool) async throws -> A"
      ),
      as: .dump
    )
  }
}
