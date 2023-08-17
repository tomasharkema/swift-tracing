//
//  File.swift
//  
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation

public typealias MainActorWork = (@Sendable @MainActor () -> ())
public typealias MainActorWorkGroup = [MainActorWork]

public extension MainActorWorkGroup {
    @MainActor
    mutating func execute() {
        let mainActorWorkCapture = self
        for work in mainActorWorkCapture {
            work()
        }
        self.removeAll()
    }
}
