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
    _ file: String = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
    let caller = Caller(file: file, line: line, function: function)

    if let previousCaller = TaskCaller.caller {
        logger.fault("🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))")
        assertionFailure("ALREADY PREVIOUS CALLER!!! \(caller)")
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

/// closest equivalent to plain old `Task { @MainActor in }`
public func dispatchTaskMain(
    priority: TaskPriority? = nil,
    @_implicitSelfCapture _ handler: @MainActor @Sendable @escaping () async -> Void,
    _ file: String = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
    let caller = Caller(file: file, line: line, function: function)

    dispatchPrecondition(condition: .onQueue(.main))

    if let previousCaller = TaskCaller.caller {
        logger.fault("🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))")
        assertionFailure("🚦 ALREADY PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))\n\n\(String(describing: previousCaller.stack))")
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
