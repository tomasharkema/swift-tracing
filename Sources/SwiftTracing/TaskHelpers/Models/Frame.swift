//
//  Frame.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation

#if DEBUG
struct Frame: CustomDebugStringConvertible {
    let index: Int
    let lib: String
    let stackPointer: String
    let mangledFunction: String
    let function: String

    init?(_ line: String) {
        if #available(iOS 16, macOS 13, *) {
            guard let match = line.firstMatch(of: FrameRegex.frameRegex) else {
                assertionFailure("STACKFRAME: line not matched: \(line)")
                return nil
            }

            index = match[FrameRegex.indexRef]
            lib = String(match[FrameRegex.libraryRef])
            stackPointer = String(match[FrameRegex.stackPointerRef])
            mangledFunction = String(match[FrameRegex.mangledFuncRef])
            function = mangledFunction.demangled

        } else {
            return nil
        }
    }

    var debugDescription: String {
        "\(function) \(index) \(lib) \(stackPointer)"
    }

    var isSwiftConcurrency: Bool {
        lib.hasPrefix("libswift_Concurrency")
    }

    var isSwiftTask: Bool {
        isSwiftConcurrency && function.contains("Task") && !function.contains("TaskLocal")
    }

    var isFromUIKit: Bool {
        lib.contains("UIKitCore") && function.contains("UIView")
    }

    var isAddObserverMain: Bool {
        lib.contains("FMCore") && function.contains("addObserverMain") && function.contains("using: @Swift.MainActor")
    }
}
#endif
