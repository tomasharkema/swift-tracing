//
//  dispatchTask.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation
import SwiftStacktrace

/// closest equivalent to plain old `Task { }`
public func dispatchTask(
  priority: TaskPriority? = nil,
  options: DispatchTaskOptions = .default,
  @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> Void,
  _ fileID: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function,
  dso: UnsafeRawPointer = #dsohandle
) {
#if DEBUG
  let caller = Caller(fileID: "\(fileID)", line: line, function: function)

  if options.contains(.assertOnAlreadyOnTaskContext), let previousCaller = TaskCaller.caller {
    logger
      .fault(
        "🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))"
      )
    assertionFailure("🚦 ALREADY PREVIOUS CALLER!!! \(caller)", file: fileID, line: line)
  }
#endif

  Task(priority: priority) {
#if DEBUG
    await TaskCaller.$caller.withValue(caller) {
      await handler()
    }
#else
    await handler()
#endif
  }
}

/// closest equivalent to plain old `Task.detached { }`
public func dispatchTaskDetached(
  priority: TaskPriority? = nil,
  options: DispatchTaskOptions = .default,
  @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> Void,
  _ fileID: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function,
  dso: UnsafeRawPointer = #dsohandle
) {
#if DEBUG
  let caller = Caller(fileID: "\(fileID)", line: line, function: function)

  if options.contains(.assertOnAlreadyOnTaskContext), let previousCaller = TaskCaller.caller {
    logger
      .fault(
        "🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))"
      )
    assertionFailure("🚦 ALREADY PREVIOUS CALLER!!! \(caller)", file: fileID, line: line)
  }
#endif

  Task.detached(priority: priority) {
#if DEBUG
    await TaskCaller.$caller.withValue(caller) {
      await handler()
    }
#else
    await handler()
#endif
  }
}

/// closest equivalent to plain old `Task { @MainActor in }`
public func dispatchTaskMain(
  priority: TaskPriority? = .userInitiated,
  options: DispatchTaskOptions = .default,
  @_implicitSelfCapture _ handler: @MainActor @Sendable @escaping () async -> Void,
  _ fileID: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
  let caller = Caller(fileID: "\(fileID)", line: line, function: function)

  if let previousCaller = TaskCaller.caller {
    logger
      .info(
        "🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))"
      )
    if options.contains(.assertOnAlreadyOnTaskContext) {
      assertionFailure(
        "🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))",
        file: fileID,
        line: line
      )
    }
  }
#endif

  Task(priority: priority) { @MainActor in
#if DEBUG
    await TaskCaller.$caller.withValue(caller) {
      dispatchPrecondition(condition: .onQueue(.main))
      await handler()
    }
#else
    await handler()
#endif
  }
}

public struct DispatchTaskOptions: OptionSet {
  public static let assertOnAlreadyOnTaskContext = DispatchTaskOptions(rawValue: 1 << 0)

  public static let `default`: DispatchTaskOptions = []

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}
