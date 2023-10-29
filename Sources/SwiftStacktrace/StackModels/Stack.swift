//
//  Stack.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation

public struct Stack: CustomDebugStringConvertible, Hashable, Equatable, Sendable {
  public let frames: [Frame]

  package init(_ lines: any Sequence<String>) {
    frames = Array(
      lines.compactMap(Frame.init)
        .drop {
          $0.isFromSwiftTracing || $0.isFromSwiftStacktrace
        }
    )
  }

  public var briefDescription: String {
    frames.map(\.briefDescription).joined(separator: "\n")
  }

  public var debugDescription: String {
    frames.map(\.debugDescription).joined(separator: "\n")
  }

  package var swiftConcurrency: Frame? {
    frames.first {
      $0.isSwiftConcurrency
    }
  }

  package var isSwiftConcurrency: Bool {
    swiftConcurrency != nil
  }

  package var isSwiftTask: Bool {
    swiftTask != nil
  }

  package var swiftTask: Frame? {
    frames.first {
      $0.isSwiftTask
    }
  }

  package var fromUIKit: Frame? {
    frames.first {
      $0.isFromUIKit
    }
  }

  package var isFromUIKit: Bool {
    fromUIKit != nil
  }

  package var fromAddObserverMain: Frame? {
    frames.first {
      $0.isAddObserverMain
    }
  }

  package var isAddObserverMain: Bool {
    fromAddObserverMain != nil
  }

  package var comingFromMainActor: Frame? {
    frames.first {
      $0.isComingFromMainActor
    }
  }

  package var isComingFromMainActor: Bool {
    comingFromMainActor != nil
  }

  package var swiftUiMainThread: (Frame, Frame)? {
    let swiftUiFrame = frames.first { $0.lib == "SwiftUI" }
    guard let swiftUiFrame else { return nil }
    let dispatchMain = frames
      .first {
        $0.lib.hasPrefix("libdispatch") && $0.functionOrMangled.contains("_dispatch_main_queue")
      }
    guard let dispatchMain else { return nil }
    return (swiftUiFrame, dispatchMain)
  }

  package var isSwiftUiMainThread: Bool {
    swiftUiMainThread != nil
  }
}
