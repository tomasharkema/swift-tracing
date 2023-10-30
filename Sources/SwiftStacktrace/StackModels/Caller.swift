//
//  Caller.swift
//
//
//  Created by Tomas Harkema on 13/08/2023.
//

import Foundation
import RegexBuilder

public class LazyCaller: LazyInitializable {
  public let fileID: String
  public let line: UInt
  public let function: String
  public let stack: LazyStack

  public lazy var initialized: Caller = .init(
    fileID: fileID,
    line: line,
    function: function,
    stack: stack
  )

  public init(
    fileID: String = #fileID,
    line: UInt = #line,
    function: String = #function,
    _ stack: any Sequence<String> = Thread.callStackSymbols
  ) {
    self.fileID = fileID
    self.line = line
    self.function = function
    self.stack = LazyStack(stack)
  }
}

public struct Caller: Hashable, Equatable, LazyContainer {
  public let file: String
  public let line: UInt
  public let function: String
  public let moduleName: String

  @HashableNoop
  public var stack: LazyStack

  public var lazy: LazyStack {
    stack
  }

  fileprivate init(
    fileID: String,
    line: UInt,
    function: String,
    stack: LazyStack
  ) {
    let splitted = fileID.split(separator: "/")

    file = String(splitted[1])
    self.line = line
    self.function = function
    moduleName = String(splitted[0])

    self.stack = stack
  }

  package func containsTaskFrame() -> Frame? {
    if #available(iOS 16, *) {
      if let frame = stack.initialized.swiftTask {
        return frame
      }

      if let frame = stack.initialized.swiftConcurrency {
        return frame
      }

      return nil

    } else {
      return nil
    }
  }

  public var isEntry: Bool {
    stack.initialized.isSwiftTask ||
      stack.initialized.isSwiftConcurrency ||
      stack.initialized.isFromUIKit ||
      stack.initialized.isAddObserverMain ||
      stack.initialized.isSwiftUiMainThread
  }

  public var comingFromMainActor: Frame? {
    stack.initialized.comingFromMainActor
  }

  public var isComingFromMainActor: Bool {
    stack.initialized.isComingFromMainActor
  }
}

extension Caller: CustomBriefStringConvertible {
  public var briefDescription: String {
    stack.briefDescription
  }
}

extension Caller: StackStringConvertible {
  public var stackFormatted: String {
    initialized.stackFormatted
  }
}

extension LazyCaller: Encodable {}

extension Caller: Encodable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(file, forKey: .file)
    try container.encode(line, forKey: .line)
    try container.encode(function, forKey: .function)
    try container.encode(moduleName, forKey: .moduleName)
    try container.encode(stack, forKey: .initialized)
  }

  enum CodingKeys: CodingKey {
    case file
    case line
    case function
    case moduleName
    case initialized
  }
}
