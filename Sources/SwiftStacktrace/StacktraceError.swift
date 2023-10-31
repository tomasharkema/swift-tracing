//
//  StacktraceError.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation

typealias StackError = StacktraceError

public protocol StacktraceErrorContainable {
  var stacktraceError: StacktraceError? { get }
}

public class StacktraceError: Error {
  public let underlyingError: any Error
  private let stacktraceClosure: () -> Caller
  package lazy var stacktrace: Caller = stacktraceClosure()

  public init(
    _ underlyingError: any Error,
    _ fileID: String = #fileID,
    _ line: UInt = #line,
    _ function: String = #function
  ) {
    // if let stack = underlyingError as? StacktraceError {
    //     self.underlyingError = stack.underlyingError
    //     self.stackTrace = stack.stackTrace
    // } else {
    self.underlyingError = underlyingError
    let lazyCaller = LazyCaller(fileID: fileID, line: line, function: function)
    stacktraceClosure = {
      lazyCaller.initialized
    }
    // }
  }

  init(
    underlyingError: any Error,
    caller: Caller
  ) {
    // if let stack = underlyingError as? StacktraceError {
    //     self.underlyingError = stack.underlyingError
    //     self.stackTrace = stack.stackTrace
    // } else {
    self.underlyingError = underlyingError
    stacktraceClosure = {
      caller
    }
    // }
  }

  private static func lastUnderlyingStackError(
    _ currentError: StacktraceError
  ) -> StacktraceError? {
    (currentError.underlyingError as? StacktraceError) ??
      (currentError.underlyingError as? any StacktraceErrorContainable)?.stacktraceError
  }

  private func chain() -> (chain: [StacktraceError], last: StacktraceError)? {
    guard let firstError = Self.lastUnderlyingStackError(self) else {
      return nil
    }

    var chain = [self, firstError]
    var currentError = firstError

    while let iteration = Self.lastUnderlyingStackError(currentError) {
      chain.append(iteration)
      currentError = iteration
    }

    return (chain: chain, last: currentError)
  }

  private func latestError() -> StacktraceError {
    if let (_, lastError) = chain() {
      lastError
    } else {
      self
    }
  }

  @StringBuilder
  private func errorChainsString(chain: [StacktraceError]) -> StringResult {
    for error in chain {
      let description = error.stacktrace.briefDescription
      "-> \(description)"
    }
  }

  @StringBuilder
  private var underlyingErrorDescription: StringResult {
    if let (chain, lastError) = self.chain() {
      let typeDescription = String(describing: type(of: underlyingError))
      let lastErrorDescription = String(describing: lastError.underlyingError)
      let chainString = errorChainsString(chain: chain.dropLast())

      "\(typeDescription): \(lastErrorDescription)"
      " "
      Indented {
        chainString
      }
      
    } else {
      let typeDescription = String(describing: type(of: underlyingError))
      let underlyingErrorDescription = String(describing: underlyingError)
      "\(typeDescription): \(underlyingErrorDescription)"
    }
  }
}

extension StacktraceError: LocalizedError {
  public var errorDescription: String? {
    underlyingError.localizedDescription
  }
}

extension StacktraceError: CustomStringConvertible {
  @StringBuilder
  public var descriptionResult: StringResult {
    "hallo?"
  }

  public var description: String {
    descriptionResult.final
  }
}

extension StacktraceError: CustomDebugStringConvertible {
  public var debugDescription: String {
    debugDescriptionResult.final
  }
  
  @StringBuilder
  public var debugDescriptionResult: StringResult {
    let stack = latestError().stacktrace
    let stackFormatted = stack.stack.initialized.stackFormattedResult

    let stacktraceDescription = stack.debugDescription
    let underlyingErrorDescriptionResult = underlyingErrorDescription
    
    underlyingErrorDescriptionResult
    ""
    Indented {
      "\(stacktraceDescription)"
      " "

      Indented {
        stackFormatted
      }
    }
    
//    return "\(descr)\n\n\t\(stacktraceDescription)\n\(stackFormatted)"
  }
}
