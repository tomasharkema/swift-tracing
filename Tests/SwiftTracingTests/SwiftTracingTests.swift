import Foundation
import XCTest
@testable import SwiftTracing
import SwiftTaskToolbox

class SwiftTracingTests: XCTestCase {

    let signposter = Signposter(subsystem: "a", category: "b")

    func testInit() async throws {
        let id = signposter.makeSignpostID()

        let result: Int = try await TracingHolder.with(signposter, id: id) {
            XCTAssertEqual(TracingHolder.signpostID, id)
            XCTAssertEqual(TracingHolder.signposter, signposter)
            try await Task.sleep(seconds: 1)
            XCTAssertEqual(TracingHolder.signpostID, id)
            XCTAssertEqual(TracingHolder.signposter, signposter)
            return 1
        }
        print(result)
    }
}
