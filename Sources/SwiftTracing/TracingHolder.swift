//
//  TracingHolder.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation
#if canImport(os)
import os
#endif

enum TracingHolder {

    @TaskLocal
    static var signposter: Signposter?

    @TaskLocal
    static var signpostID: SignpostID?

    static func with<R>(
        _ signposter: Signposter,
        id: SignpostID,
        operation: () throws -> R,
        file: String = #fileID, line: UInt = #line
    ) rethrows -> R {
        return try $signposter.withValue(signposter, operation: {
            return try $signpostID.withValue(id, operation: {
                return try operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }

    static func with<R>(
        _ signposter: Signposter,
        id: SignpostID,
        operation: () async throws -> R,
        file: String = #fileID, line: UInt = #line
    ) async rethrows -> R {
        return try await $signposter.withValue(signposter, operation: {
            return try await $signpostID.withValue(id, operation: {
                return try await operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }

    static func withNewId<R>(
        _ signposter: Signposter,
        operation: () throws -> R,
        file: String = #fileID, line: UInt = #line
    ) rethrows -> R {
        let id = signposter.makeSignpostID()

        return try TracingHolder.with(signposter, id: id, operation: {
            try operation()
        }, file: file, line: line)
    }

    static func withNewId<R>(
        _ signposter: Signposter,
        operation: () async throws -> R,
        file: String = #fileID, line: UInt = #line
    ) async rethrows -> R {
        let id = signposter.makeSignpostID()

        return try await TracingHolder.with(signposter, id: id, operation: {
            try await operation()
        }, file: file, line: line)
    }

    static func withNewId<R>(
        operation: () throws -> R,
        file: String = #fileID, line: UInt = #line
    ) rethrows -> R {
        return try withNewId(TracingHolder.signposter!, operation: operation, file: file, line: line)
    }

    static func withNewId<R>(
        operation: () async throws -> R,
        file: String = #fileID, line: UInt = #line
    ) async rethrows -> R {
        return try await withNewId(TracingHolder.signposter!, operation: operation, file: file, line: line)
    }
}

// @available(iOS 15, *)
// extension TracingHolder {

//     static func with<R>(
//         _ signposter: Signposter,
//         id signpostID: OSSignpostID,
//         operation: () throws -> R,
//         file: String = #fileID, line: UInt = #line
//     ) rethrows -> R {
//         return try $signposter.withValue(signposter, operation: {
//             return try $signpostID.withValue(SignpostID(signpostID), operation: {
//                 return try operation()
//             }, file: file, line: line)
//         }, file: file, line: line)
//     }

//     static func with<R>(
//         _ signposter: Signposter,
//         id signpostID: OSSignpostID,
//         operation: () async throws -> R,
//         file: String = #fileID, line: UInt = #line
//     ) async rethrows -> R {
//         return try await $signposter.withValue(signposter, operation: {
//             return try await $signpostID.withValue(SignpostID(signpostID), operation: {
//                 return try await operation()
//             }, file: file, line: line)
//         }, file: file, line: line)
//     }
// }
