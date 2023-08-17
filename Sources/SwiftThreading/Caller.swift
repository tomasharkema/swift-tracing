//
//  Caller.swift
//  
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation
import RegexBuilder
import SwiftDemangle

struct Caller: CustomDebugStringConvertible {
    let file: String
    let line: UInt
    let function: String
    
    let stack: Stack

    init(file: String, line: UInt, function: String, stack: any Sequence<String> = Thread.callStackSymbols.dropFirst(2)) {
        self.file = file
        self.line = line
        self.function = function

        self.stack = Stack(stack)
    }

    var debugDescription: String {
        return "\(function) - \(URL(fileURLWithPath: file).lastPathComponent):\(line)"
    }

    func containsTaskFrame() -> Frame? {
        if #available(iOS 16, *) {

            if let frame = stack.swiftTask {
//                logger.info("stack isSwiftTask true\n\n\(String(describing: stack))")
                return frame
            }

            if let frame = stack.swiftConcurrency {
//                logger.info("stack isSwiftConcurrency true\n\n\(String(describing: stack))")
                return frame
            }

            return nil

        } else {
            return nil
        }
    }

    var isEntry: Bool {
        stack.isSwiftTask ||
        stack.isSwiftConcurrency ||
        stack.isFromUIKit ||
        stack.isAddObserverMain ||
        stack.isSwiftUiMainThread
    }
}

struct Stack: CustomDebugStringConvertible {
    let frames: [Frame]

    init(_ lines: any Sequence<String>) {
        frames = lines.compactMap(Frame.init)
    }

    var debugDescription: String {
        frames.map { $0.debugDescription }.joined(separator: "\n")
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

struct Frame: CustomDebugStringConvertible {

    let index: Int
    let lib: String
    let stackPointer: String
    let mangledFunction: String
    let function: String

    init?(_ line: String) {
        if #available(iOS 16, *) {

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

@available(iOS 16.0, *)
enum FrameRegex {

    static let indexRef = Reference(Int.self)
    static let libraryRef = Reference(Substring.self)
    static let stackPointerRef = Reference(Substring.self)
    static let mangledFuncRef = Reference(Substring.self)

    /// basically `/\S/`
    static let sentence: CharacterClass = .whitespace.inverted.subtracting(.newlineSequence)

    /// Parsing the following format:
    /// "6   libswift_Concurrency.dylib          0x00000001b1641d25 $ss9TaskLocalC9withValue_9operation4file4lineqd__x_qd__yYaKXESSSutYaKlFTQ0_ + 1"
    static let frameRegex = Regex {
        TryCapture(as: indexRef) {
            OneOrMore(.digit)
        } transform: { match in
            Int(match)
        }

        OneOrMore(.whitespace)

        Capture(as: libraryRef) {
            OneOrMore(Self.sentence)
        }

        OneOrMore(.whitespace)

        Capture(as: stackPointerRef) {
            OneOrMore(Self.sentence)
        }

        OneOrMore(.whitespace)

        Capture(as: mangledFuncRef) {
            OneOrMore(.anyNonNewline)
        }
    }
}
