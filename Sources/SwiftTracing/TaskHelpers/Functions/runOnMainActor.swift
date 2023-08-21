//
//  runOnMainActor.swift
//
//
//  Created by Tomas Harkema on 11/08/2023.
//

import Foundation

/// closest equivalent to plain old `Task { @MainActor in }`, with extra safety mechanisms.
/// This function will be very complainy and strict about when already called on `@MainActor`.
public func runOnMainActor(
    priority: TaskPriority? = .userInitiated,
    options: RunOnMainActorOptions = .default,
    @_implicitSelfCapture _ handler: @Sendable @escaping @MainActor () async -> Void,
    _ file: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
    innerDebug(priority: priority, options: options, handler, file, line, function)
#else
    Task(priority: priority) { @MainActor in
        await handler()
    }
#endif
}

// does not work
//@available(*, deprecated, message: "Already called from @MainActor. Possibly not needed?")
//@MainActor
//public func runOnMainActor(
//    priority: TaskPriority? = nil,
//    options: RunOnMainActorOptions = .default,
//    @_implicitSelfCapture _ handler: @Sendable @escaping @MainActor () -> Void,
//    _ file: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function
//) {
//#if DEBUG
//    assertionFailure("NOT EXECUTING!")
//#else
//    Task(priority: priority) { @MainActor in
//        await handler()
//    }
//#endif
//}

#if DEBUG

@_transparent
@inline(__always)
func innerDebug(
    priority: TaskPriority?,
    options: RunOnMainActorOptions,
    @_implicitSelfCapture _ handler: @Sendable @escaping @MainActor () async -> Void,
    _ file: StaticString, _ line: UInt, _ function: String,
    _ currentFunction: String = #function
) {

    let caller = Caller(file: file, line: line, function: function)

    let previousCaller = TaskCaller.caller

    let isEntry = options.contains(.isEntry)

    if !isEntry, previousCaller == nil {
        if options.contains(.allowMainThreadWithoutEntry), Thread.isMainThread, caller.isEntry {
            logger.info("🚦 Coming from main thread without clear entry. Allowing... \(function): \(currentFunction)")
        } else {
            logger.fault("🚦 Not called from a task context: \(String(describing: caller)). No previous context.\n\n\(String(describing: caller.stack)) \(function): \(currentFunction)")
            assertionFailure("🚦 Not called from a task context: \(caller). No previous context \(function): \(currentFunction)", file: file, line: line)
            return
        }
    }

    if options.contains(.assertWhenAlreadyFromMainActor), let frame = caller.comingFromMainActor {
        assertionFailure("🚦 Already coming from @MainActor \(caller) \(frame)", file: file, line: line)
    }

    if caller.isComingFromMainActor {
        runtimeWarning("🚦 Already coming called from @MainActor. %@", "\(function): \(currentFunction)")
    } else if Thread.isMainThread {
        runtimeWarning("🚦 Already coming called from MainThread. %@", "\(function): \(currentFunction)")
    }

    let taskFrame = caller.containsTaskFrame()

    if Thread.isMainThread {
        logger.trace("""
        🚦 already called from main thread: caller: \(String(describing: caller)) previousCaller: \(String(describing: previousCaller))
        \(String(describing: Task.currentPriority)) taskFrame: \(String(describing: taskFrame))
        """)
        if !isEntry, !caller.isEntry {
            logger.trace("🚦 but not is entry! \(function)")
        }
    } else {
        logger.trace("""
        🚦 called from thread: caller: \(String(describing: caller)) previousCaller: \(String(describing: previousCaller))
        \(String(describing: Task.currentPriority)) \(String(describing: Thread.current))
        taskFrame: \(String(describing: taskFrame))
        """)
    }

    if isEntry, !caller.isEntry {
        logger.notice("🚦 isEntry true; for stack: \(function): \(currentFunction)\n\n\(String(describing: caller.stack))")
    }

    if !isEntry, !caller.isEntry {
        logger.notice("🚦 isEntry false; for stack: \(function): \(currentFunction)\n\n\(String(describing: caller.stack))")
    }

    Task(priority: priority) { @MainActor in
        await TaskCaller.$caller.withValue(caller) { @MainActor in
            await handler()
        }
    }
}

#endif

public struct RunOnMainActorOptions: OptionSet {

    public static let isEntry = RunOnMainActorOptions(rawValue: 1 << 0)
    public static let allowMainThreadWithoutEntry = RunOnMainActorOptions(rawValue: 1 << 1)
    public static let assertWhenAlreadyFromMainActor = RunOnMainActorOptions(rawValue: 1 << 2)

    public static let `default`: RunOnMainActorOptions = [.assertWhenAlreadyFromMainActor]

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
