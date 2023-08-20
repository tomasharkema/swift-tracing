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

extension MainActorWorkGroup {
    public mutating func task(
        priority: MainActorTaskPriority,
        _ task: @Sendable @MainActor @escaping () -> Void,
        _ function: StaticString = #function
    ) {
        if priority == .high {
            insert({
                task()
            }, at: 0)
        } else {
            append {
                task()
            }
        }
    }
}
