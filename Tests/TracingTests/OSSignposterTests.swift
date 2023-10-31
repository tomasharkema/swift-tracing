//
//  OSSignposterTests.swift
//
//
//  Created by Tomas Harkema on 19/08/2023.
//

import Foundation
import OSLog
import SwiftTaskToolbox
@testable import SwiftTracing
import XCTest

class OSSignposterTests: XCTestCase {
  let signposter = Signposter(subsystem: "a", category: "b")

  func testInit() async throws {
    _ = try await signposter.measure(withNewId: "ojoo") {
      XCTAssertNotNil(TracingHolder.signpostID)
      XCTAssertNotNil(TracingHolder.signposter)
      try await Task.sleep(seconds: 1)
      XCTAssertNotNil(TracingHolder.signpostID)
      XCTAssertNotNil(TracingHolder.signposter)
      return 1
    }
  }
}
