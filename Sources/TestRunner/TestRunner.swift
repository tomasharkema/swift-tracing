//
//  TestRunner.swift
//
//
//  Created by Tomas Harkema on 20/08/2023.
//

import Foundation
import SwiftStacktrace
import SwiftTracing

@main
enum TestApp {
  static let signposter = Signposter(subsystem: "a", category: "b")

  static func main() async throws {
#if DEBUG
    print("DEBUG")
#endif
#if RELEASE
    print("RELEASE")
#endif

    for _ in 0 ... 1000 {
      try await measure()
    }
  }

  static func measure() async throws {
    try await signposter.measure(withNewId: "A") {
      print("A")
      if #available(macOS 13.0, *) {
        try await Task.sleep(for: .seconds(1))
      } else {
        // Fallback on earlier versions
      }
      print("B")
    }
  }
}
