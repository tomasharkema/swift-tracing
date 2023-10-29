import Foundation

typealias StackError = StacktraceError

public protocol StacktraceErrorContainable {
  var stacktraceError: StacktraceError? { get }
}

public struct StacktraceError: Error {
  public let underlyingError: any Error
  public let stacktrace: Caller

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
    stacktrace = Caller(fileID: fileID, line: line, function: function)
    // }
  }

  private static func lastUnderlyingStackError(_ currentError: StacktraceError)
    -> StacktraceError?
  {
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

  private func underlyingErrorDescription() -> String {
    if let (chain, lastError) = self.chain() {
      let chainString = chain.dropLast()
        .map(\.stacktrace.briefDescription)
        .map { "\t-> \($0)" }
        .joined(separator: "\n")
      let lastErrorDescription = String(describing: lastError.underlyingError)
      return "\(type(of: underlyingError)): \(lastErrorDescription)\n\n\(chainString)"
    } else {
      return "\(type(of: underlyingError)): \(underlyingError)"
    }
  }
}

extension StacktraceError: LocalizedError {
  public var errorDescription: String? {
    underlyingError.localizedDescription
  }
}

extension StacktraceError: CustomDebugStringConvertible {
  public var debugDescription: String {
    let descr = underlyingErrorDescription()
    let stack = latestError().stacktrace
    let stackFormatted = stack.stack.frames
      .map {
        if let functionInfo = $0.functionInfo {
          return "\t\tat: \(functionInfo.debugDescription)"
        } else {
          return "\t\t\tat: \($0)"
        }
      }
      .joined(separator: "\n")

    let stacktraceDescription = stack.debugDescription

    return "\(descr)\n\n\t\(stacktraceDescription)\n\(stackFormatted)"
  }
}
