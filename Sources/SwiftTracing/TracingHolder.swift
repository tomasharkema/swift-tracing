//
//  TracingHolder.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation
import OSLog

public enum TracingHolder {

    @TaskLocal
    static var signposter: Signposter?

    @TaskLocal
    static var signpostID: SignpostID?

    public static func with<R>(
        _ signposter: Signposter,
        id: SignpostID,
        operation: () throws -> R,
        file: String = #fileID, line: UInt = #line
    ) rethrows -> R {
        return try $signposter.withValue(signposter, operation: {
            return try $signpostID.withValue(signpostID, operation: {
                return try operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }

    public static func with<R>(
        _ signposter: Signposter,
        id: SignpostID,
        operation: () async throws -> R,
        file: String = #fileID, line: UInt = #line
    ) async rethrows -> R {
        return try await $signposter.withValue(signposter, operation: {
            return try await $signpostID.withValue(signpostID, operation: {
                return try await operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }


    public static func with(
        _ signposter: Signposter,
        id: SignpostID,
        operation: () throws -> Void,
        file: String = #fileID, line: UInt = #line
    ) rethrows {
        try $signposter.withValue(signposter, operation: {
            try $signpostID.withValue(signpostID, operation: {
                try operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }

    public static func with(
        _ signposter: Signposter,
        id: SignpostID,
        operation: () async throws -> Void,
        file: String = #fileID, line: UInt = #line
    ) async rethrows {
        try await $signposter.withValue(signposter, operation: {
            try await $signpostID.withValue(signpostID, operation: {
                try await operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }
}

@available(iOS 15, *)
extension TracingHolder {

    public static func with<R>(
        _ signposter: Signposter,
        id signpostID: OSSignpostID,
        operation: () throws -> R,
        file: String = #fileID, line: UInt = #line
    ) rethrows -> R {
        return try $signposter.withValue(signposter, operation: {
            return try $signpostID.withValue(SignpostID(signpostID), operation: {
                return try operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }

    public static func with<R>(
        _ signposter: Signposter,
        id signpostID: OSSignpostID,
        operation: () async throws -> R,
        file: String = #fileID, line: UInt = #line
    ) async rethrows -> R {
        return try await $signposter.withValue(signposter, operation: {
            return try await $signpostID.withValue(SignpostID(signpostID), operation: {
                return try await operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }
}
