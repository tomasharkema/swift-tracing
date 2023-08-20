//
//  MainActorWorkGroup.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation

/// A mechanism to group work for the main actor.
public typealias MainActorWorkGroup = [MainActorWork]

public extension MainActorWorkGroup {
    @MainActor
    mutating func execute() {
        let mainActorWorkCapture = self
        for work in mainActorWorkCapture {
            work()
        }
        removeAll()
    }
}

public typealias MainActorWork = @Sendable @MainActor () -> Void
