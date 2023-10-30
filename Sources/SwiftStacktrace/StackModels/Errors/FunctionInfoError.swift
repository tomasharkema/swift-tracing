import Foundation

public enum FunctionInfoError: Error {
  case parseError(ParseError)
  case otherError(any Error)
}

extension FunctionInfoError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .parseError(error):
      error.description

    case let .otherError(error):
      String(describing: error)
    }
  }
}

extension FunctionInfoError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case let .parseError(error):
      error.description

    case let .otherError(error as any LocalizedError):
      error.errorDescription

    case let .otherError(error):
      String(describing: error)
    }
  }
}
