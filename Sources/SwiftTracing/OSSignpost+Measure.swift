//
//  OSSignpost+Measure.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation

// extension SignpostID {
//    public func measure<T>(signposter: Signposter, name: StaticString, operation: () async -> T) async -> T {
//        let state = signposter.beginInterval(name, id: self)
//        defer {
//            signposter.endInterval(name, state)
//        }
//        return await task()
//    }
//
//    public func measure<T>(signposter: Signposter, name: StaticString, operation: () -> T) -> T {
//        let state = signposter.beginInterval(name, id: self)
//        defer {
//            signposter.endInterval(name, state)
//        }
//        return task()
//    }
// }

extension Signposter {
    /// Measure a asynchronous task.
    func measure<T>(
        signpostID: SignpostID, name: StaticString, operation: () async throws -> T,
        file _: StaticString = #fileID, line _: UInt = #line
    ) async rethrows -> T {
        let state = beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return try await operation()
    }

    /// Measure a synchronous task.
    func measure<T>(
        signpostID: SignpostID, name: StaticString, operation: () throws -> T,
        file _: StaticString = #fileID, line _: UInt = #line
    ) rethrows -> T {
        let state = beginInterval(name, id: signpostID)
        defer {
            self.endInterval(name, state)
        }
        return try operation()
    }

    /// Measure a asynchronous task.
    public func measure<T>(
        withNewId name: StaticString, operation: () async throws -> T,
        file: StaticString = #fileID, line: UInt = #line
    ) async rethrows -> T {
        try await TracingHolder.$signposter.withValue(self, operation: {
            try await TracingHolder.withNewId(operation: {
                guard let signpostID = TracingHolder.signpostID else {
                    assertionFailure("TracingHolder not set", file: file, line: line)
                    return try await operation()
                }
                return try await measure(signpostID: signpostID, name: name, operation: operation, file: file, line: line)
            }, file: file, line: line)
        }, file: "\(file)", line: line)
    }

    /// Measure a synchronous task.
    public func measure<T>(
        withNewId name: StaticString, operation: () throws -> T,
        file: StaticString = #fileID, line: UInt = #line
    ) rethrows -> T {
        try TracingHolder.$signposter.withValue(self, operation: {
            try TracingHolder.withNewId(operation: {
                guard let signpostID = TracingHolder.signpostID else {
                    assertionFailure("TracingHolder not set", file: file, line: line)
                    return try operation()
                }

                return try measure(signpostID: signpostID, name: name, operation: operation, file: file, line: line)
            }, file: file, line: line)
        }, file: "\(file)", line: line)
    }
}

/// Measure a synchronous task, by creating a new SignpostID.
public func measure<T>(
    withNewId name: StaticString, operation: () throws -> T,
    file: StaticString = #fileID, line: UInt = #line
) rethrows -> T {
    try TracingHolder.withNewId(operation: {
        try measure(name, operation: {
            try operation()
        }, file: file, line: line)
    }, file: file, line: line)
}

/// Measure a asynchronous task.
public func measure<T>(
    withNewId name: StaticString, operation: () async throws -> T,
    file: StaticString = #fileID, line: UInt = #line
) async rethrows -> T {
    try await TracingHolder.withNewId(operation: {
        try await measure(name, operation: {
            try await operation()
        }, file: file, line: line)
    }, file: file, line: line)
}

/// Measure a synchronous task, by creating a new SignpostID.
public func measure<T>(
    _ name: StaticString, operation: () throws -> T,
    file: StaticString = #fileID, line: UInt = #line
) rethrows -> T {
    guard let signposter = TracingHolder.signposter, let signpostID = TracingHolder.signpostID else {
        assertionFailure("TracingHolder not set", file: file, line: line)
        return try operation()
    }
    return try signposter.measure(signpostID: signpostID, name: name, operation: {
        try operation()
    }, file: file, line: line)
}

/// Measure a asynchronous task.
public func measure<T>(
    _ name: StaticString, operation: () async throws -> T,
    file: StaticString = #fileID, line: UInt = #line
) async rethrows -> T {
    guard let signposter = TracingHolder.signposter, let signpostID = TracingHolder.signpostID else {
        assertionFailure("TracingHolder not set", file: file, line: line)
        return try await operation()
    }
    return try await signposter.measure(signpostID: signpostID, name: name, operation: {
        try await operation()
    }, file: file, line: line)
}

// extension TracingHolder {
//    static func measureTask<T>(name: StaticString, operation: () async -> T) async -> T {
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
//    static func measureTask<T>(name: StaticString, operation: () throws -> T) rethrows -> T {
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
//            return try operation()
//        }
//        return try operation()
//    }
// }
