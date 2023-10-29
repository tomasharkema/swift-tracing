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
  func trace(_: String) {}
  func fault(_: String) {}
  func info(_: String) {}
  func notice(_: String) {}
}

#endif
