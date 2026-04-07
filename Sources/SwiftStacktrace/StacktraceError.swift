//
//  StacktraceError.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation
import StringsBuilder

typealias StackError = StacktraceError

public protocol StacktraceErrorContainable {
  var stacktraceError: StacktraceError? { get }
}

enum EitherCaller {
  case lazy(LazyCaller)
  case caller(Caller)

  var initialized: Caller {
    switch self {
    case .lazy(let caller):
      return caller.initialized
    case .caller(let caller):
      return caller
    }
  }
}

public final class StacktraceError: Error, Sendable {
  public let underlyingError: any Error
  private let caller: EitherCaller

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
    caller = .lazy(LazyCaller(fileID: fileID, line: line, function: function))
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
    self.caller = .caller(caller)
    // }
  }

  private static func lastUnderlyingStackError(
    _ currentError: StacktraceError
  ) -> StacktraceError? {
    (currentError.underlyingError as? StacktraceError)
      ?? (currentError.underlyingError as? any StacktraceErrorContainable)?.stacktraceError
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

  package var stacktrace: Caller {
    caller.initialized
  }

  @StringBuilder
  private func errorChainsString(chain: [StacktraceError]) -> any StringConvertible {
    for error in chain {
      "-> \(error.stacktrace.briefDescription)"
    }
  }

  @StringBuilder
  private var underlyingErrorDescription: any StringConvertible {
    if let (chain, lastError) = self.chain() {
      let typeDescription = String(describing: type(of: underlyingError))
      let lastErrorDescription = String(describing: lastError.underlyingError)
      let chainString = errorChainsString(chain: chain.dropLast())

      "\(typeDescription): \(lastErrorDescription)"
      Empty()
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
  package var descriptionResult: any StringConvertible {
    "hallo?"
  }

  public var description: String {
    descriptionResult.string
  }
}

extension StacktraceError: CustomDebugStringConvertible {
  public var debugDescription: String {
    debugDescriptionResult.string
  }

  @StringBuilder
  package var debugDescriptionResult: any StringConvertible {
    underlyingErrorDescription
    Empty()
    Indented {
      "\(self.latestError().stacktrace.debugDescription)"
      Empty()
      Indented {
        self.stacktrace.stack.initialized.stackFormattedResult
      }
    }

    //    return "\(descr)\n\n\t\(stacktraceDescription)\n\(stackFormatted)"
  }
}
