import Foundation
#if canImport(os)
import os
#endif

public struct SignpostID: Equatable, Hashable {
    let rawValue: os_signpost_id_t

    @available(iOS 15, *)
    init(_ id: os.OSSignpostID) {
        rawValue = id.rawValue
    }

    init() {
        rawValue = .min
    }

    @available(iOS 15, *)
    var osSignpostID: os.OSSignpostID {
        os.OSSignpostID(rawValue)
    }
}
