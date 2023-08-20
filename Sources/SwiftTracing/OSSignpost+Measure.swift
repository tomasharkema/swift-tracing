//
//  OSSignpost+Measure.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation
import OSLog

//extension SignpostID {
//    public func measureTask<T>(signposter: Signposter, name: StaticString, _ task: () async -> T) async -> T {
//        let state = signposter.beginInterval(name, id: self)
//        defer {
//            signposter.endInterval(name, state)
//        }
//        return await task()
//    }
//
//    public func measureTask<T>(signposter: Signposter, name: StaticString, _ task: () -> T) -> T {
//        let state = signposter.beginInterval(name, id: self)
//        defer {
//            signposter.endInterval(name, state)
//        }
//        return task()
//    }
//}

extension Signposter {

    /// Measure a asynchronous task.
    public func measureTask<T>(signpostID: SignpostID, name: StaticString, _ task: () async throws -> T) async rethrows -> T {
        let state = beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return try await task()
    }

    /// Measure a synchronous task.
    public func measureTask<T>(signpostID: SignpostID, name: StaticString, _ task: () throws -> T) rethrows -> T {
        let state = beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return try task()
    }

    /// Measure a asynchronous task, by creating a new SignpostID.
    public func measureTask<T>(withNewId name: StaticString, _ task: () async throws -> T) async rethrows -> T {
        return try await TracingHolder.withNewId(self, operation: {
            try await task()
        })
    }

    /// Measure a synchronous task, by creating a new SignpostID.
    public func measureTask<T>(withNewId name: StaticString, _ task: () throws -> T) rethrows -> T {
        return try TracingHolder.withNewId(self, operation: {
            try task()
        })
    }
}

//extension TracingHolder {
//    static func measureTask<T>(name: StaticString, _ task: () async -> T) async -> T {
//        if #available(iOS 15, *) {
//            guard let signposter = TracingHolder.signposter else {
//                fatalError("NO signposter!")
//            }
//            guard let signpostId = TracingHolder.signpostID else {
//                fatalError("NO signpostId!")
//            }
//
//            let state = signposter.beginInterval(name, id: signpostId)
//            defer {
//                signposter.endInterval(name, state)
//            }
//
//            return await task()
//        }
//
//        return await task()
//    }
//
//    static func measureTask<T>(name: StaticString, _ task: () throws -> T) rethrows -> T {
//        if #available(iOS 15, *) {
//            guard let signposter, let signpostId = signpostID else {
//                fatalError("NO TRACE!")
//            }
//
//            let state = signposter.beginInterval(name, id: signpostId)
//            defer {
//                signposter.endInterval(name, state)
//            }
//
//            return try task()
//        }
//        return try task()
//    }
//}
