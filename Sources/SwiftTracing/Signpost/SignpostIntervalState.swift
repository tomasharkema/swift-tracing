import Foundation
#if canImport(os)
import os
#endif

public struct SignpostIntervalState: Equatable, Hashable {
  let json: Data

  @available(iOS 15, *)
  init(_ state: os.OSSignpostIntervalState) throws {
    json = try JSONEncoder().encode(state)
  }

  init() {
    json = Data()
  }
}
