//
//  Caller.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation
import RegexBuilder

public struct Caller: CustomDebugStringConvertible, Hashable, Equatable, Sendable,
  SourcecodeLocation
{
  public let file: String
  public let line: UInt
  public let function: String
  public let moduleName: String

  public let stack: Stack

  package init(
    _ fileID: String = #fileID,
    _ line: UInt = #line,
    _ function: String = #function,
    stack: any Sequence<String> = Thread.callStackSymbols
  ) {
    self.init(fileID: fileID, line: line, function: function, stack: stack)
  }

  public init(
    fileID: String,
    line: UInt,
    function: String,
    stack: any Sequence<String> = Thread.callStackSymbols
  ) {
    let splitted = fileID.split(separator: "/")

    file = String(splitted[1])
    self.line = line
    self.function = function
    moduleName = String(splitted[0])

    self.stack = Stack(stack)
  }

  package func containsTaskFrame() -> Frame? {
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

  public var isEntry: Bool {
    stack.isSwiftTask ||
      stack.isSwiftConcurrency ||
      stack.isFromUIKit ||
      stack.isAddObserverMain ||
      stack.isSwiftUiMainThread
  }

  public var comingFromMainActor: Frame? {
    stack.comingFromMainActor
  }

  public var isComingFromMainActor: Bool {
    comingFromMainActor != nil
  }
}
