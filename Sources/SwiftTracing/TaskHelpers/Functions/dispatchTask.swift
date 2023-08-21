//
//  dispatchTask.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation

/// closest equivalent to plain old `Task { }`
public func dispatchTask(
    priority: TaskPriority? = nil,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> Void,
    _ file: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
    let caller = Caller(file: file, line: line, function: function)

    if let previousCaller = TaskCaller.caller {
        logger.fault("🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))")
        assertionFailure("ALREADY PREVIOUS CALLER!!! \(caller)", file: file, line: line)
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
    _ options: DispatchTaskOptions = .default,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> Void,
    _ file: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
    let caller = Caller(file: file, line: line, function: function)

    if options.contains(.assertOnAlreadyOnTaskContext), let previousCaller = TaskCaller.caller {
        logger.fault("🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))")
        assertionFailure("ALREADY PREVIOUS CALLER!!! \(caller)", file: file, line: line)
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
    priority: TaskPriority? = nil,
    @_implicitSelfCapture _ handler: @MainActor @Sendable @escaping () async -> Void,
    _ file: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
    let caller = Caller(file: file, line: line, function: function)

    dispatchPrecondition(condition: .onQueue(.main))

    if let previousCaller = TaskCaller.caller {
        logger.fault("🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))")
        assertionFailure("🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))", file: file, line: line)
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

    public static let `default`: DispatchTaskOptions = [.assertOnAlreadyOnTaskContext]
    public static let noOptions: DispatchTaskOptions = []

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
