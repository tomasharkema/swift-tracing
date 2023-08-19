//
//  OSSignposterTests.swift
//  
//
//  Created by Tomas Harkema on 19/08/2023.
//

import Foundation
import XCTest
@testable import SwiftTracing
import SwiftTaskToolbox
import OSLog

class OSSignposterTests: XCTestCase {

    let signposter = Signposter(subsystem: "a", category: "b")

    func testInit() async throws {
        let id = signposter.makeSignpostID()

        let result: Int = try await TracingHolder.with(signposter, id: id) {
            XCTAssertNotNil(TracingHolder.signpostID)
            XCTAssertNotNil(TracingHolder.signposter)
            try await Task.sleep(seconds: 1)
            XCTAssertNotNil(TracingHolder.signpostID)
            XCTAssertNotNil(TracingHolder.signposter)
            return 1
        }
        print(result)
    }
}
