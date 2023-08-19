//
//  MainActorWorkGroup+Tracing.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation

public enum MainActorTaskPriority {
    case high
    case low
}

public extension MainActorWorkGroup {
    mutating func task(
        priority: MainActorTaskPriority,
        _ task: @Sendable @MainActor @escaping () -> Void,
        _ function: StaticString = #function
    ) {
        if priority == .high {
            insert({
                try? TracingHolder.measureTask(name: function) {
                    task()
                }
            }, at: 0)
        } else {
            append {
                try? TracingHolder.measureTask(name: function) {
                    task()
                }
            }
        }
    }
}
