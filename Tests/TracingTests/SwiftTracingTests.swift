import Foundation
// import SwiftTaskToolbox
import Testing

@testable import SwiftTracing

struct SwiftTracingTests {
  private let signposter = Signposter(subsystem: "a", category: "b")

  @Test
  func testInit() async throws {
    let id = signposter.makeSignpostID()

    _ = try await TracingHolder.with(signposter, id: id) {
      #expect(TracingHolder.signpostID == id)
      #expect(TracingHolder.signposter == signposter)
      try await Task.sleep(until: .now + .seconds(1))
      #expect(TracingHolder.signpostID == id)
      #expect(TracingHolder.signposter == signposter)
      return 1
    }
  }
}
