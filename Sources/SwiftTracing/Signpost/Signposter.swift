import Foundation
import os

/// A helper class for OSSignposter for iOS <= 14
public struct Signposter: Equatable, Hashable {
    let subsystem: String
    let category: String

    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    @available(iOS 15, *)
    var osSignposter: os.OSSignposter {
        os.OSSignposter(subsystem: subsystem, category: category)
    }

    public func makeSignpostID() -> SignpostID {
        if #available(iOS 15, *) {
            let id = osSignposter.makeSignpostID()
            return SignpostID(id)
        } else {
            return SignpostID()
        }
    }

    public func beginInterval(_ name: StaticString, id: SignpostID) -> SignpostIntervalState {
        if #available(iOS 15, *) {
            do {
                let state = osSignposter.beginInterval(name, id: id.osSignpostID)
                return try SignpostIntervalState(state)
            } catch {
                assertionFailure("\(error)")
                return SignpostIntervalState()
            }
        } else {
            return SignpostIntervalState()
        }
    }

    public func endInterval(_ name: StaticString, _ state: SignpostIntervalState) {
        if #available(iOS 15, *) {
            do {
                let state = try JSONDecoder().decode(OSSignpostIntervalState.self, from: state.json)
                osSignposter.endInterval(name, state)
            } catch {
                assertionFailure("\(error)")
            }
        }
    }
}

public typealias OSSignposter = Signposter
