//
//  Caller.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation
import RegexBuilder
import SwiftDemangle

#if DEBUG
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
        "\(function) - \(URL(fileURLWithPath: file).lastPathComponent):\(line)"
    }

    func containsTaskFrame() -> Frame? {
        if #available(iOS 16, *) {
            if let frame = stack.swiftTask {
                return frame
            }

            if let frame = stack.swiftConcurrency {
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
#endif
