//
//  File.swift
//  
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation
import OSLog

public extension OSSignpostID {
    func measureTask<T>(signposter: OSSignposter, name: StaticString, _ task: () async -> T) async -> T {
        let state = signposter.beginInterval(name, id: self)
        defer {
            signposter.endInterval(name, state)
        }
        return await task()
    }

    func measureTask<T>(signposter: OSSignposter, name: StaticString, _ task: () -> T) -> T {
        let state = signposter.beginInterval(name, id: self)
        defer {
            signposter.endInterval(name, state)
        }
        return task()
    }
}

public extension OSSignposter {
    func measureTask<T>(signpostID: OSSignpostID, name: StaticString, _ task: () async -> T) async -> T {
        let state = self.beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return await task()
    }

    func measureTask<T>(signpostID: OSSignpostID, name: StaticString, _ task: () -> T) -> T {
        let state = self.beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return task()
    }
}

public extension TracingHolder {
    static func measureTask<T>(name: StaticString, _ task: () async -> T) async -> T {
        guard let signposter = signposter, let signpostId = signpostID else {
            fatalError("NO TRACE!")
        }

        let state = signposter.beginInterval(name, id: signpostId)
        defer {
            signposter.endInterval(name, state)
        }

        return await task()
    }

    static func measureTask<T>(name: StaticString, _ task: () -> T) -> T {
        guard let signposter = signposter, let signpostId = signpostID else {
            fatalError("NO TRACE!")
        }

        let state = signposter.beginInterval(name, id: signpostId)
        defer {
            signposter.endInterval(name, state)
        }

        return task()
    }
}
