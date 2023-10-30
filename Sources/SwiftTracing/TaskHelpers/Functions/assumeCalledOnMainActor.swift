//
//  assumeCalledOnMainActor.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation
import SwiftStacktrace

public func assumeCalledOnMainActor(
  priority: TaskPriority = .userInitiated,
  options: AssumeCalledOnMainActorOptions = .default,
  @_implicitSelfCapture _ handler: @Sendable @escaping @MainActor () async -> Void,
  _ fileID: StaticString = #fileID, _ line: UInt = #line, _ function: String = #function
) {
#if DEBUG
  let caller = LazyCaller(fileID: "\(fileID)", line: line, function: function).initialized

//    dispatchPrecondition(condition: .onQueue(.main))

  let previousCaller = TaskCaller.caller

  let isEntry = options.contains(.isEntry)

  if !isEntry, previousCaller == nil {
    if options.contains(.allowMainThreadWithoutEntry), Thread.isMainThread, caller.isEntry {
      logger
        .info("🚦 Coming from main thread. Allowing... assumeCalledOnMainActor \(function)")

      if Settings.runtimeWarnings.contains(.allowMainThreadWithoutEntryNoMainActor) {
        if !caller.isComingFromMainActor {
          runtimeWarning(
            "🚦 Function not explicitly called from a @MainActor annotated function. %@",
            "assumeCalledOnMainActor: \(function)"
          )
        }
      }
    } else {
      logger
        .fault(
          "🚦 NO PREVIOUS CALLER!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))"
        )
      assertionFailure("🚦 NO PREVIOUS CALLER!!!", file: fileID, line: line)
      return
    }
  }

  let taskFrame = caller.containsTaskFrame()

  if !caller.isEntry, taskFrame == nil, !isEntry {
    logger
      .fault(
        "🚦 NO PREVIOUS TASK!!! \(String(describing: caller))\n\n\(String(describing: caller.stack))"
      )
    assertionFailure("🚦 NO PREVIOUS TASK!!!", file: fileID, line: line)
  }

  if !caller.isEntry, !caller.stack.initialized.isFromUIKit, !isEntry {
    assertionFailure("🚦 not from uikit??", file: fileID, line: line)
  }

  guard Task.currentPriority.rawValue >= 25 else {
    logger
      .fault(
        "🚦 assumeCalledOnMainActor not right prio \(String(describing: Task.currentPriority)) \(String(describing: caller))\n\n\(String(describing: caller.stack))"
      )
    assertionFailure(
      "🚦 assumeCalledOnMainActor not right prio \(Task.currentPriority) caller: \(caller) previousCaller: \(previousCaller)",
      file: fileID,
      line: line
    )
    return
  }
#endif

  Task(priority: priority) { @MainActor in
#if DEBUG
    await TaskCaller.$caller.withValue(caller) {
      await handler()
    }
#else
    await handler()
#endif
  }
}

public struct AssumeCalledOnMainActorOptions: OptionSet {
  public static let isEntry = AssumeCalledOnMainActorOptions(rawValue: 1 << 0)
  public static let allowMainThreadWithoutEntry = AssumeCalledOnMainActorOptions(rawValue: 1 << 1)

  public static let `default`: AssumeCalledOnMainActorOptions = .allowMainThreadWithoutEntry

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}
