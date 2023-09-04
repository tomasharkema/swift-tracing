//
//  PrintObservableChanges.swift
//
//
//  Created by Tomas Harkema on 04/09/2023.
//

import Foundation
import SwiftUI
import Combine

#if DEBUG

var cancableForFileLocation = [Caller: AnyCancellable]()

public extension ObservableObject {
    func _printChanges(_ file: String = #file, _ line: UInt = #line, _ function: String = #function) {
        let caller = Caller(file: file, line: line, function: function)

        cancableForFileLocation[caller] = objectWillChange.sink { _ in
            self.stackHelper()
        }
    }

    private func stackHelper(_ file: String = #file, _ line: UInt = #line, _ function: String = #function) {
        let caller = Caller(file: file, line: line, function: function)

        let latest = caller.stack.frames
            .drop {
                !$0.lib.contains("Combine")
            }
            .drop {
                $0.lib.contains("Combine")
            }
            .dropFirst(1)
            .first

        if let latest {
            print("STACK: \(latest)")
        }
    }
}

#endif
