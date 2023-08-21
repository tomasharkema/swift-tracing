#if canImport(os)
import os
#else
// swiftlint:disable:next type_name
typealias os_signpost_id_t = Int

// swiftlint:disable:next type_name
enum os {
    struct OSSignpostIntervalState: Codable {}

    struct OSSignposter {
        let subsystem: String
        let category: String

        init(subsystem: String, category: String) {
            self.subsystem = subsystem
            self.category = category
        }

        func beginInterval(_: StaticString, id _: OSSignpostID) -> OSSignpostIntervalState {
            OSSignpostIntervalState()
        }

        func endInterval(_: StaticString, _: OSSignpostIntervalState) {}
        func makeSignpostID() -> OSSignpostID {
            OSSignpostID(.min)
        }
    }

    struct OSSignpostID {
        let rawValue: os_signpost_id_t

        init(_ rawValue: os_signpost_id_t) {
            self.rawValue = rawValue
        }
    }
}

#endif
