//
//  assumeCalledOnMainActor.swift
//  
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation

public func assumeCalledOnMainActor(
    priority: TaskPriority = .userInitiated,
    isEntry: Bool = false,
    @_implicitSelfCapture _ handler: @Sendable @escaping @MainActor () async -> (),
    _ file: String = #fileID, _ line: UInt = #line, _ function: String = #function
) {
    let caller = Caller(file: file, line: line, function: function)

#if DEBUG
    dispatchPrecondition(condition: .onQueue(.main))

    let previousCaller = TaskCaller.caller

    if !isEntry, previousCaller == nil, !caller.isEntry {
        logger.fault("🚦 NO PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))")
        assertionFailure("NO PREVIOUS CALLER!!!")
    }

    let taskFrame = caller.containsTaskFrame()

    if !caller.isEntry, taskFrame == nil, !isEntry {
        logger.fault("🚦 NO PREVIOUS TASK!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))")
        assertionFailure("NO PREVIOUS TASK!!!")
    }

    if !caller.isEntry, caller.stack.isFromUIKit != nil, !isEntry {
        assertionFailure("not from uikit??")
    }

    guard Task.currentPriority.rawValue >= 25 else {
        logger.fault("🚦 assumeCalledOnMainActor not right prio \(String(describing: Task.currentPriority)) \(String(describing: caller))\n\n\(String(describing: caller.stack))")
        assertionFailure("assumeCalledOnMainActor not right prio \(Task.currentPriority) caller: \(caller) previousCaller: \(previousCaller)")
        return
    }
#endif

    Task(priority: priority) { @MainActor in
        await TaskCaller.$caller.withValue(caller) {
            await handler()
        }
    }
}
