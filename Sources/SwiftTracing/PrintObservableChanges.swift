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
    let caller = LazyCaller(
      fileID: fileID,
      line: line,
      function: function
    )

    cancableForFileLocation[caller.initialized] = objectWillChange.sink { _ in
      self.stackHelper()
    }
  }

  private func stackHelper(
    _ fileID: String = #fileID,
    _ line: UInt = #line,
    _ function: String = #function,
    dso _: UnsafeRawPointer = #dsohandle
  ) {
    let caller = LazyCaller(fileID: fileID, line: line, function: function).initialized

    let latest = caller.stack.initialized.frames
      .drop {
        !$0.initialized.lib.contains("Combine")
      }
      .drop {
        $0.initialized.lib.contains("Combine")
      }
      .dropFirst(1)
      .first

    if let latest {
      print("STACK: \(latest)")
    }
  }
}

#endif
