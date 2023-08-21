//
//  runOnMainActor.swift
//
//
//  Created by Tomas Harkema on 11/08/2023.
//

import Foundation

public func runOnMainActor(
    isEntry: Bool = false,
    @_implicitSelfCapture _ handler: @Sendable @escaping @MainActor () async -> Void,
    _ file: String = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
    let caller = Caller(file: file, line: line, function: function)

    let previousCaller = TaskCaller.caller

    if !isEntry, previousCaller == nil {
        logger.fault("🚦 NO PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))")
        assertionFailure("NO PREVIOUS CALLER!!! \(caller)")
        return
    }

    let taskFrame = caller.containsTaskFrame()

    if Thread.isMainThread {
        logger.trace("""
        🚦 already called from main thread: caller: \(String(describing: caller)) previousCaller: \(String(describing: previousCaller))
        \(String(describing: Task.currentPriority)) taskFrame: \(String(describing: taskFrame))
        """)
        if !isEntry, !caller.isEntry {
            logger.trace("🚦 but not is entry!")
        }
    } else {
        logger.trace("""
        🚦 called from thread: caller: \(String(describing: caller)) previousCaller: \(String(describing: previousCaller))
        \(String(describing: Task.currentPriority)) \(String(describing: Thread.current))
        taskFrame: \(String(describing: taskFrame))
        """)
    }

    if isEntry, !caller.isEntry {
        logger.notice("isEntry true; for stack:\n\n\(String(describing: caller.stack))")
    }

    if !isEntry, !caller.isEntry {
        logger.notice("isEntry false; for stack:\n\n\(String(describing: caller.stack))")
    }

#endif

    Task(priority: .userInitiated) { @MainActor in
#if DEBUG
        await TaskCaller.$caller.withValue(caller) { @MainActor in
            await handler()
        }
#else
        await handler()
#endif
    }
}
