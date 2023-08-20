import Foundation
import os

public struct SignpostIntervalState: Equatable, Hashable {
    let json: Data

    @available(iOS 15, *)
    init(_ state: OSSignpostIntervalState) throws {
        json = try JSONEncoder().encode(state)
    }

    init() {
        json = Data()
    }
}