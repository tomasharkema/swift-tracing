//
//  Frame.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation

public struct Frame: CustomDebugStringConvertible, Hashable, Equatable, Sendable {
  public let index: Int
  public let lib: String
  public let stackPointer: String
  public let mangledFunction: String
  public let function: String?
  public let functionInfo: FunctionInfo?

  package init?(_ line: String) {
    guard #available(iOS 16, macOS 13, *) else {
      return nil
    }

    guard let match = line.firstMatch(of: FrameRegex.frameRegex) else {
      assertionFailure("STACKFRAME: line not matched: \(line)")
      return nil
    }

    index = match[FrameRegex.indexRef]
    lib = String(match[FrameRegex.libraryRef])
    stackPointer = String(match[FrameRegex.stackPointerRef])
    mangledFunction = String(match[FrameRegex.mangledFuncRef])
    let demangled = swift_demangle(mangledFunction)
    let cleanupped = demangled.flatMap { cleanup(line: $0) }
    function = cleanupped
    do {
      functionInfo = try cleanupped.flatMap { try FunctionInfo($0) }
    } catch {
      // print(error)
      functionInfo = nil
    }
  }

  public var debugDescription: String {
    let functionText: String
    if let functionInfo {
      functionText = functionInfo.debugDescription
    } else {
      functionText = "raw: \(function ?? mangledFunction)"
    }
    
    return "\(functionText) \(index) \(lib) \(stackPointer)"
  }

  public var briefDescription: String {
    "\(function?.description ?? String(mangledFunction.prefix(10))) \(index) \(lib) \(stackPointer)"
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
    lib.contains("SwiftTracing") || functionOrMangled
      .contains("SwiftTracing.") || mangledFunction.contains("$s12SwiftTracing")
  }

  var isFromSwiftStacktrace: Bool {
    lib.contains("SwiftStacktrace")
  }
}

func cleanup(line: String) -> String {
  if #available(macOS 13.0, *) {
    let cleanupRegex = /^((\([0-9]+\)) )?((suspend) )?((?<await>await) )?((resume) )?((partial) )?((function) )?((for) )?((default) (argument) ([0-9]+) (of) )?(?<functionDecl>.*)/
    
    if let match = line.firstMatch(of: cleanupRegex) {
      return "\(match.output.functionDecl)"
    }
  }

  return line
}
