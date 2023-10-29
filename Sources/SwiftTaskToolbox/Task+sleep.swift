//
//  Task+sleep.swift
//  SwiftTaskToolbox
//
//  Created by Tomas Harkema on 03/08/2023.
//  Copyright © 2023 Flitsmeister B.V. All rights reserved.
//

#if canImport(Darwin)
import Darwin

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension Task where Failure == Never, Success == Never {
  static func sleep(seconds: Double) async throws {
    try await sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
  }
}
#endif
