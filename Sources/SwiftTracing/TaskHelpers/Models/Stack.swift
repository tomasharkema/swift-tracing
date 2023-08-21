//
//  Stack.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation

#if DEBUG
struct Stack: CustomDebugStringConvertible {
    let frames: [Frame]

    init(_ lines: any Sequence<String>) {
        frames = lines.compactMap(Frame.init)
    }

    var debugDescription: String {
        frames.map(\.debugDescription).joined(separator: "\n")
    }

    var swiftConcurrency: Frame? {
        frames.first {
            $0.isSwiftConcurrency
        }
    }

    var isSwiftConcurrency: Bool {
        swiftConcurrency != nil
    }

    var isSwiftTask: Bool {
        swiftTask != nil
    }

    var swiftTask: Frame? {
        frames.first {
            $0.isSwiftTask
        }
    }

    var fromUIKit: Frame? {
        frames.first {
            $0.isFromUIKit
        }
    }

    var isFromUIKit: Bool {
        fromUIKit != nil
    }

    var fromAddObserverMain: Frame? {
        frames.first {
            $0.isAddObserverMain
        }
    }

    var isAddObserverMain: Bool {
        fromAddObserverMain != nil
    }

    var swiftUiMainThread: (Frame, Frame)? {
        let swiftUiFrame = frames.first { $0.lib == "SwiftUI" }
        guard let swiftUiFrame else { return nil }
        let dispatchMain = frames.first { $0.lib.hasPrefix("libdispatch") && $0.function.contains("_dispatch_main_queue") }
        guard let dispatchMain else { return nil }
        return (swiftUiFrame, dispatchMain)
    }

    var isSwiftUiMainThread: Bool {
        swiftUiMainThread != nil
    }
}
#endif
