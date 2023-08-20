import Foundation
import os

public struct SignpostID: Equatable, Hashable {

    public let rawValue: os_signpost_id_t

    @available(iOS 15, *)
    init(_ id: OSSignpostID) {
        self.rawValue = id.rawValue
    }

    init() {
        rawValue = .min
    }

    @available(iOS 15, *)
    var osSignpostID: OSSignpostID {
        return OSSignpostID(rawValue)
    }
}