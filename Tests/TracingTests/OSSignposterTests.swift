//
//  OSSignposterTests.swift
//
//
//  Created by Tomas Harkema on 19/08/2023.
//

#if canImport(OSLog)

  import Foundation
  import OSLog
  import Testing

  @testable import SwiftTracing

  struct OSSignposterTests {
    let signposter = Signposter(subsystem: "a", category: "b")

    @Test
    func testInit() async throws {
      _ = try await signposter.measure(withNewId: "ojoo") {
        #expect(TracingHolder.signpostID != nil)
        #expect(TracingHolder.signposter != nil)
        try await Task.sleep(until: .now + .seconds(1))
        #expect(TracingHolder.signpostID != nil)
        #expect(TracingHolder.signposter != nil)
        return 1
      }
    }
  }

#endif
