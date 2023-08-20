#if canImport(os)
import os
#else

typealias os_signpost_id_t = Int

struct os {

    struct OSSignpostIntervalState: Codable {
        
    }
    struct OSSignposter {
        let subsystem: String
        let category: String

        init(subsystem: String, category: String) {
            self.subsystem = subsystem
            self.category = category
        }
        
        func beginInterval(_ name: StaticString, id: OSSignpostID) -> OSSignpostIntervalState {
            return OSSignpostIntervalState()
        }
        func endInterval(_ name: StaticString, _ state: OSSignpostIntervalState) {}
        func makeSignpostID() -> OSSignpostID {
            return OSSignpostID(.min)
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