//
//  printComingFromThread.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation

public func printComingFromThread(
    priority: TaskPriority? = nil,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> Void,
    _ file: String = #fileID, _ line: UInt = #line, _ function: String = #function
) {
    let caller = Caller(file: file, line: line, function: function)

    let previousCaller = TaskCaller.caller

#if DEBUG

    if !caller.isEntry, previousCaller == nil {
        logger.fault("🚦 NO PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))")
        assertionFailure("NO PREVIOUS CALLER!!! \(caller)")
        return
    }

    let taskFrame = caller.containsTaskFrame()

    let header = "🚦 print from thread: caller:"
    let callers = "\(String(describing: caller)) previousCaller: \(String(describing: TaskCaller.caller))"
    logger.trace("""
    \(header) \(callers) \(String(describing: Task.currentPriority))
    \(String(describing: Thread.current)) taskFrame: \(String(describing: taskFrame))
    """)

    if !caller.isEntry {
        logger.trace("🚦 !!not from an entry!")
    }
#endif

    Task(priority: priority) {
        await TaskCaller.$caller.withValue(caller) {
            await handler()
        }
    }
}
