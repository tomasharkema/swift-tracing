//
//  OSSignpost+Measure.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation
import OSLog

public extension SignpostID {
    func measureTask<T>(signposter: Signposter, name: StaticString, _ task: () async -> T) async -> T {
        let state = signposter.beginInterval(name, id: self)
        defer {
            signposter.endInterval(name, state)
        }
        return await task()
    }

    func measureTask<T>(signposter: Signposter, name: StaticString, _ task: () -> T) -> T {
        let state = signposter.beginInterval(name, id: self)
        defer {
            signposter.endInterval(name, state)
        }
        return task()
    }
}

public extension Signposter {
    func measureTask<T>(signpostID: SignpostID, name: StaticString, _ task: () async -> T) async -> T {
        let state = beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return await task()
    }

    func measureTask<T>(signpostID: SignpostID, name: StaticString, _ task: () -> T) -> T {
        let state = beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return task()
    }
}

public extension TracingHolder {
    static func measureTask<T>(name: StaticString, _ task: () async -> T) async -> T {
        if #available(iOS 15, *) {
            guard let signposter = TracingHolder.signposter else {
                fatalError("NO signposter!")
            }
            guard let signpostId = TracingHolder.signpostID else {
                fatalError("NO signpostId!")
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
