//
//  printComingFromThread.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

#if DEBUG
import Foundation

/// Helper to log from which task/thread this function is called. This function is purely for initial debugging purposed
/// and should not be used in Release builds. Hence this function is not available in Release configuration.
///
/// After debugging, use ``dispatchTaskMain(priority:_:_:_:_:)`` or ``runOnMainActor(isEntry:_:_:_:_:)``
///
/// This helps getting a hang of Task dispatches such as `Task { }` or `Task { @MainActor in }` are really needed.
///
/// - Parameters:
///   - priority: The priority of the task. Pass nil to use the priority from Task.currentPriority.
///   - allowFromMainThread: set to `true` if call blocking from `MainActor` or main thread is allowed.
///   - handler: The operation to perform.
public func _printComingFromThread(
    priority: TaskPriority? = nil,
    allowFromMainThread: Bool = false,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> Void,
    _ file: StaticString = #file, _ line: UInt = #line, _ function: String = #function
) {
    innerDebug(priority: priority, allowFromMainThread: allowFromMainThread, handler, file, line, function)
}

/// Helper to log from which task/thread this function is called.This function is purely for initial debugging purposed
/// and should not be used in Release builds. Hence this function is not available in Release configuration.
/// 
/// After debugging, use ``dispatchTaskMain(priority:_:_:_:_:)`` or ``runOnMainActor(isEntry:_:_:_:_:)``
///
/// This helps getting a hang of Task dispatches such as `Task { }` or `Task { @MainActor in }` are really needed.
///
/// - Parameters:
///   - allowFromMainThread: set to `true` if call blocking from `MainActor` or main thread is allowed.
///   - handler: The operation to perform.
public func _printComingFromThread<ReturnType>(
    allowFromMainThread: Bool = false,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> ReturnType,
    _ file: StaticString = #file, _ line: UInt = #line, _ function: String = #function
) async -> ReturnType {
    return await innerDebug(allowFromMainThread: allowFromMainThread, handler, file, line, function)
}

@_transparent
@inline(__always)
func innerDebugResult(
    allowFromMainThread: Bool,
    _ file: StaticString, _ line: UInt, _ function: String
) -> (Caller, Bool) {
    let caller = Caller(file: "\(file)", line: line, function: function)

    if allowFromMainThread && Thread.isMainThread {
        if Settings.runtimeWarnings.contains(.calledOnMainThread) {
            runtimeWarning("🚦 Called from main thread. Allowing this. %@", function)
        } else {
            logger.trace("🚦 \(function) Called from main thread. Allowing this.\n\n\(String(describing: caller.stack))")
        }

        return (caller, true)
    }

    let previousCaller = TaskCaller.caller

    if !caller.isEntry, previousCaller == nil {
        if Settings.runtimeWarnings.contains(.noPreviousCaller) {
            runtimeWarning("🚦 Not called from a task context %@", "\(String(describing: caller))")
        }

        assertionFailure("🚦 Not called from a task context \(caller)", file: file, line: line)
        return (caller, false)
    }

    let taskFrame = caller.containsTaskFrame()

    let header = "🚦 print from thread: caller:"
    let callers = "\(String(describing: caller)) previousCaller: \(String(describing: TaskCaller.caller))"
    logger.trace("""
    \(header) \(callers) \(String(describing: Task.currentPriority))
    \(String(describing: Thread.current)) taskFrame: \(String(describing: taskFrame))
    """)

    if Settings.runtimeWarnings.contains(.printComingFromThread) {
        runtimeWarning("🚦 print from thread: caller: %@", callers)
    }

    if !caller.isEntry {
        if Settings.runtimeWarnings.contains(.notFromAnEntry) {
            runtimeWarning("🚦 !!not from an entry!")
        }
        logger.trace("🚦 !!not from an entry!")
    }

    return (caller, true)
}

@_transparent
@inline(__always)
func innerDebug(
    priority: TaskPriority?,
    allowFromMainThread: Bool,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> Void,
    _ file: StaticString, _ line: UInt, _ function: String
) {
    let (caller, result) = innerDebugResult(allowFromMainThread: allowFromMainThread, file, line, function)

    innerDebugTaskCall(caller: caller, priority: priority, handler)
}

@_transparent
@inline(__always)
func innerDebug<ReturnType>(
    allowFromMainThread: Bool,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> ReturnType,
    _ file: StaticString, _ line: UInt, _ function: String
) async -> ReturnType {
    let (caller, result) = innerDebugResult(allowFromMainThread: allowFromMainThread, file, line, function)

    return await innerDebugTaskCall(caller: caller, handler)
}

@_transparent
@inline(__always)
func innerDebugTaskCall<ReturnType>(
    caller: Caller,
    priority: TaskPriority?,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> ReturnType
) {
    Task(priority: priority) {
        await TaskCaller.$caller.withValue(caller) {
            return await handler()
        }
    }
}

@_transparent
@inline(__always)
func innerDebugTaskCall<ReturnType>(
    caller: Caller,
    @_implicitSelfCapture @_inheritActorContext _ handler: @Sendable @escaping () async -> ReturnType
) async -> ReturnType {
    return await TaskCaller.$caller.withValue(caller) {
        return await handler()
    }
}

#endif
