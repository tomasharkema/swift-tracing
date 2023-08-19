//
//  OSSignpost+Measure.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation
import OSLog

public extension SignpostID {
    func measureTask<T>(signposter: Signposter, name: StaticString, _ task: () async -> T) async throws -> T {
        let state = try signposter.beginInterval(name, id: self)
        defer {
            try? signposter.endInterval(name, state)
        }
        return await task()
    }

    func measureTask<T>(signposter: Signposter, name: StaticString, _ task: () -> T) throws -> T {
        let state = try signposter.beginInterval(name, id: self)
        defer {
            try? signposter.endInterval(name, state)
        }
        return task()
    }
}

public extension Signposter {
    func measureTask<T>(signpostID: SignpostID, name: StaticString, _ task: () async -> T) async throws -> T {
        let state = try beginInterval(name, id: signpostID)
        defer {
            try? self.endInterval(name, state)
        }
        return await task()
    }

    func measureTask<T>(signpostID: SignpostID, name: StaticString, _ task: () -> T) throws -> T {
        let state = try beginInterval(name, id: signpostID)
        defer {
            try? self.endInterval(name, state)
        }
        return task()
    }
}

public extension TracingHolder {
    static func measureTask<T>(name: StaticString, _ task: () async -> T) async -> T {
        if #available(iOS 15, *) {
            guard let signposter, let signpostId = signpostID else {
                fatalError("NO TRACE!")
            }

            let state = signposter.beginInterval(name, id: signpostId)
            defer {
                signposter.endInterval(name, state)
            }

            return await task()
        }

        return await task()
    }

    static func measureTask<T>(name: StaticString, _ task: () -> T) -> T {
        if #available(iOS 15, *) {
            guard let signposter, let signpostId = signpostID else {
                fatalError("NO TRACE!")
            }

            let state = signposter.beginInterval(name, id: signpostId)
            defer {
                signposter.endInterval(name, state)
            }

            return task()
        }
        return task()
    }
}
