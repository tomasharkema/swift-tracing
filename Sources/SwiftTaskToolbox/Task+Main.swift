//
//  Task+Main.swift
//
//
//  Created by Tomas Harkema on 16/08/2023.
//

import Foundation

private func checkMainThread() {
    dispatchPrecondition(condition: .notOnQueue(.main))

#if DEBUG
    if Thread.current.isMainThread {
        print("ALREADY ON MAIN THREAD!")
    }
#endif
}

public func dispatchMainActor(@_implicitSelfCapture operation: @MainActor @escaping () -> Void) {
    checkMainThread()
    Task { @MainActor in
        operation()
    }
}

public func dispatchMainActor(@_implicitSelfCapture operation: @escaping @Sendable @MainActor () async -> Void) {
    checkMainThread()
    Task { @MainActor in
        await operation()
    }
}
