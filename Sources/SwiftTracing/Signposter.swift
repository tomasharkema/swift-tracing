import Foundation
import OSLog

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

public struct Signposter: Equatable, Hashable {
    let subsystem: String
    let category: String

    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    @available(iOS 15, *)
    var osSignposter: OSSignposter { 
        OSSignposter(subsystem: subsystem, category: category) 
    }

    public func makeSignpostID() -> SignpostID {
        if #available(iOS 15, *) { 
            let id = osSignposter.makeSignpostID()
            return SignpostID(id)
        } else {
            return SignpostID()
        }
    }

    public func beginInterval(_ name: StaticString, id: SignpostID) throws -> SignpostIntervalState {
        if #available(iOS 15, *) { 
            let state = osSignposter.beginInterval(name, id: id.osSignpostID)
            return try SignpostIntervalState(state)
        } else {
            return SignpostIntervalState()
        }
    }

    public func endInterval(_ name: StaticString, _ state: SignpostIntervalState) throws {
        if #available(iOS 15, *) {
            let state = try JSONDecoder().decode(OSSignpostIntervalState.self, from: state.json)
            osSignposter.endInterval(name, state)
        }
    }
}