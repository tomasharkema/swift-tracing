//
//  Stack.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation

public class LazyStack: LazyInitializable {
  private let raw: [String]

  public lazy var initialized: Stack = .init(raw)

  package init(_ lines: any Sequence<String>) {
    raw = Array(lines)
  }
}

public struct Stack: Hashable, Equatable, LazyContainer {
  public typealias LazyType = [LazyFrame]

  private let raw: [String]

  @HashableNoop
  public var frames: [LazyFrame]

  public var lazy: [LazyFrame] {
    frames
  }

  fileprivate init(_ lines: any Sequence<String>) {
    raw = Array(lines)
    frames = Array(lines.compactMap(LazyFrame.init))
    // .drop {
    //   $0.isFromSwiftTracing || $0.isFromSwiftStacktrace
    // })
  }

  package var swiftConcurrency: Frame? {
    frames.first {
      $0.initialized.isSwiftConcurrency
    }?.initialized
  }

  package var isSwiftConcurrency: Bool {
    swiftConcurrency != nil
  }

  package var isSwiftTask: Bool {
    swiftTask != nil
  }

  package var swiftTask: Frame? {
    frames.first {
      $0.initialized.isSwiftTask
    }?.initialized
  }

  package var fromUIKit: Frame? {
    frames.first {
      $0.initialized.isFromUIKit
    }?.initialized
  }

  package var isFromUIKit: Bool {
    fromUIKit != nil
  }

  package var fromAddObserverMain: Frame? {
    frames.first {
      $0.initialized.isAddObserverMain
    }?.initialized
  }

  package var isAddObserverMain: Bool {
    fromAddObserverMain != nil
  }

  package var comingFromMainActor: Frame? {
    frames.first {
      $0.initialized.isComingFromMainActor
    }?.initialized
  }

  package var isComingFromMainActor: Bool {
    comingFromMainActor != nil
  }

  package var swiftUiMainThread: (Frame, Frame)? {
    let swiftUiFrame = frames.first { $0.initialized.lib == "SwiftUI" }?.initialized
    guard let swiftUiFrame else { return nil }
    let dispatchMain = frames
      .first {
        $0.initialized.lib.hasPrefix("libdispatch") && $0.initialized.functionOrMangled
          .contains("_dispatch_main_queue")
      }?.initialized
    guard let dispatchMain else { return nil }
    return (swiftUiFrame, dispatchMain)
  }

  package var isSwiftUiMainThread: Bool {
    swiftUiMainThread != nil
  }

  package func containsTaskFrame() -> Frame? {
    if #available(iOS 16, *) {
      if let frame = swiftTask {
        return frame
      }

      if let frame = swiftConcurrency {
        return frame
      }

      return nil

    } else {
      return nil
    }
  }

  public var isEntry: Bool {
    isSwiftTask ||
      isSwiftConcurrency ||
      isFromUIKit ||
      isAddObserverMain ||
      isSwiftUiMainThread
  }
}

public protocol StackStringConvertible {
  var stackFormatted: String { get }
}

extension Stack: StackStringConvertible {
  public var stackFormatted: String {
    frames
      .map {
        switch $0.initialized.functionInfo {
        case let .success(functionInfo):
          "\t\tat: \(functionInfo.debugDescription)"

        case let .failure(error):
          "\t\t\tat: \($0) \(error)"
        }
      }
      .joined(separator: "\n")
  }
}

extension Stack: CustomDebugStringConvertible {
  public var debugDescription: String {
    frames.map(\.debugDescription).joined(separator: "\n")
  }
}

extension Stack: CustomBriefStringConvertible {
  public var briefDescription: String {
    frames.map(\.briefDescription).joined(separator: "\n")
  }
}

extension LazyStack: Encodable {}

extension Stack: Encodable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(raw, forKey: .raw)
    try container.encode(frames, forKey: .initialized)
  }

  enum CodingKeys: CodingKey {
    case raw
    case initialized
  }
}
