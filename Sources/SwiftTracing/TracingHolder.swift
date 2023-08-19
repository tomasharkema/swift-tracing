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

    public static func with(
        signposter: Signposter,
        signpostID: SignpostID,
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
        signposter: Signposter,
        signpostID: SignpostID,
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
