//
//  Frame.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation
import SwiftSyntax

public class LazyFrame: LazyInitializable {
  package let raw: String

  public lazy var initialized: Frame = .init(raw)

  package init(_ line: String) {
    raw = line
  }
}

public struct Frame: Hashable, Equatable, Sendable, Encodable {
  public let index: Int
  public let lib: String
  public let stackPointer: String
  public let mangledFunction: String
  public let function: String?

  @HashableNoop
  public private(set) var functionInfo: Result<FunctionInfo, FunctionInfoError>

  fileprivate init(_ line: String) {
    guard #available(macOS 13, iOS 16, *),
          let match = line.firstMatch(of: FrameRegex.frameRegex)
    else {
      assertionFailure("STACKFRAME: line not matched: \(line)")
      index = 0
      lib = "ERROR"
      stackPointer = "ERROR"
      mangledFunction = "ERROR"
      function = nil
      functionInfo = .failure(.otherError(NSError(domain: "", code: 0)))
      return
    }

    index = match[FrameRegex.indexRef]
    lib = String(match[FrameRegex.libraryRef])
    stackPointer = String(match[FrameRegex.stackPointerRef])
    mangledFunction = String(match[FrameRegex.mangledFuncRef])
    let demangled = swift_demangle(mangledFunction)
    let cleanupped = demangled.flatMap { cleanup(line: $0) }
    function = cleanupped

    let functionInfo = cleanupped
      .flatMap { line in
        Result {
          try FunctionInfo(line)
        }.mapError { error in
          if let error = error as? ParseError {
            FunctionInfoError.parseError(error)
          } else {
            FunctionInfoError.otherError(error)
          }
        }
      }
    if let functionInfo {
      self.functionInfo = functionInfo
    } else {
      self.functionInfo = .failure(.otherError(NSError(domain: "", code: 0)))
    }
  }

  package var functionOrMangled: String {
    function ?? mangledFunction
  }

  package var isSwiftConcurrency: Bool {
    lib.hasPrefix("libswift_Concurrency")
  }

  package var isSwiftTask: Bool {
    isSwiftConcurrency && functionOrMangled.contains("Task") && !functionOrMangled
      .contains("TaskLocal")
  }

  package var isFromUIKit: Bool {
    (lib.contains("UIKitCore") || lib.contains("libswiftUIKit")) &&
      (functionOrMangled.contains("UIView") || functionOrMangled.contains("UIApplicationMain"))
  }

  package var isAddObserverMain: Bool {
    isFromSwiftTracing && functionOrMangled.contains("addObserverMain") && isComingFromMainActor
  }

  package var isComingFromMainActor: Bool {
    functionOrMangled.contains("using: @Swift.MainActor")
  }

  var isFromSwiftTracing: Bool {
    if lib.contains("SwiftTracing") {
      return true
    } else if case .success(let functionInfo) = functionInfo, let base = functionInfo.functionType?.base {
      return base == "SwiftTracing"
    } else {
      return functionOrMangled.contains("SwiftTracing.") || mangledFunction.contains("$s12SwiftTracing")
    }
  }

  var isFromSwiftStacktrace: Bool {
    if lib.contains("SwiftStacktrace") {
      return true
    } else if case .success(let functionInfo) = functionInfo, let base = functionInfo.functionType?.base {
      return base == "SwiftStacktrace"
    } else {
      return functionOrMangled.contains("SwiftStacktrace.") || mangledFunction.contains("$s12SwiftStacktrace")
    }
  }
}

extension Frame: CustomDebugStringConvertible {
  public var debugDescription: String {
    let functionText: String = switch functionInfo {
    case let .success(result):
      result.debugDescription
    case let .failure(error):
      "\(function ?? mangledFunction)" // \(error)"
    }

    return "\(functionText) \(index) \(lib)" // \(stackPointer)"
  }
}

extension Frame: CustomBriefStringConvertible {
  public var briefDescription: String {
    "\(function?.description ?? String(mangledFunction.prefix(10))) \(index) \(lib) \(stackPointer)"
  }
}

extension LazyFrame: Encodable {}

func cleanup(line: String) -> String {
  if #available(macOS 13.0, iOS 16, *) {
    let cleanupRegex =
      /^((\([0-9]+\)) )?((suspend) )?((?<await>await) )?((resume) )?((partial) )?((function) )?((for) )?((default) (argument) ([0-9]+) (of) )?(?<functionDecl>.*)/

    if let match = line.firstMatch(of: cleanupRegex) {
      return "\(match.output.functionDecl)"
    }
  }

  return line
}
