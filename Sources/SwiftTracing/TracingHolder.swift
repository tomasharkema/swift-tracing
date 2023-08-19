//
//  TracingHolder.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation
import OSLog

public enum TracingHolder {

    @available(iOS 15.0, *)
    @TaskLocal
    static var signposter: OSSignposter?

    @available(iOS 15.0, *)
    @TaskLocal
    static var signpostID: OSSignpostID?

    @available(iOS 15.0, *)
    public static func with(
        signposter: OSSignposter,
        signpostID: OSSignpostID,
        operation: () throws -> Void,
        file: String = #fileID, line: UInt = #line
    ) rethrows {
        try $signposter.withValue(signposter, operation: {
            try $signpostID.withValue(signpostID, operation: {
                try operation()
            }, file: file, line: line)
        }, file: file, line: line)
    }

    @available(iOS 15.0, *)
    public static func with(
        signposter: OSSignposter,
        signpostID: OSSignpostID,
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
