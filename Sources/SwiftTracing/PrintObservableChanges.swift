//
//  PrintObservableChanges.swift
//
//
//  Created by Tomas Harkema on 04/09/2023.
//

import Combine
import Foundation
import SwiftStacktrace
import SwiftUI

#if DEBUG

var cancableForFileLocation = [Caller: AnyCancellable]()

public extension ObservableObject {
  func _printChanges(
    _ fileID: String = #fileID,
    _ line: UInt = #line,
    _ function: String = #function,
    dso _: UnsafeRawPointer = #dsohandle
  ) {
    let caller = Caller(fileID: fileID, line: line, function: function)

    cancableForFileLocation[caller] = objectWillChange.sink { _ in
      self.stackHelper()
    }
  }

  private func stackHelper(
    _ fileID: String = #fileID,
    _ line: UInt = #line,
    _ function: String = #function,
    dso _: UnsafeRawPointer = #dsohandle
  ) {
    let caller = Caller(fileID: fileID, line: line, function: function)

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
