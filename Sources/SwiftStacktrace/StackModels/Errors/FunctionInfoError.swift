import Foundation

public enum FunctionInfoError: Error, Sendable {
    case parseError(ParseError)
    case otherError(any Error)
}

extension FunctionInfoError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .parseError(let error):
            error.description

        case .otherError(let error):
            String(describing: error)
        }
    }
}

extension FunctionInfoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parseError(let error):
            error.description

        case .otherError(let error as any LocalizedError):
            error.errorDescription

        case .otherError(let error):
            String(describing: error)
        }
    }
}
