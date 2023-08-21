//
//  Logger.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

#if canImport(OSLog)

import OSLog

let logger = Logger(subsystem: "SwiftTracing", category: "SwiftTracing")

#else

let logger = Logger()

struct Logger {
    func trace(_ message: String) { }
    func fault(_ message: String) { }
    func info(_ message: String) { }
    func notice(_ message: String) { }
}

#endif
