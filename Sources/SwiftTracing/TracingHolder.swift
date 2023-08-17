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
    public static var signposter: OSSignposter?
    @TaskLocal
    public static var signpostID: OSSignpostID?

    @discardableResult
    @inlinable public static func with(
        signposter: OSSignposter,
        signpostID: OSSignpostID,
        operation: () throws -> (),
        file: String = #fileID, line: UInt = #line
    ) rethrows {
        try $signposter.withValue(signposter, operation: {
            try $signpostID.withValue(signpostID, operation: {
                try operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }

    @discardableResult
    @inlinable public static func with(
        signposter: OSSignposter,
        signpostID: OSSignpostID,
        operation: () async throws -> (),
        file: String = #fileID, line: UInt = #line
    ) async rethrows {
        try await $signposter.withValue(signposter, operation: {
            try await $signpostID.withValue(signpostID, operation: {
                try await operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }
}

