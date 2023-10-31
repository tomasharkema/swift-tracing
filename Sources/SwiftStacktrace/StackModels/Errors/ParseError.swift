import Foundation
import SwiftSyntax

public struct ParseError: Error {
  let expr: any SyntaxProtocol
  let reason: Reason
  let file: String
  let line: UInt

  init(expr: any SyntaxProtocol, reason: Reason, _ file: String = #fileID, _ line: UInt = #line) {
    self.expr = expr
    self.reason = reason
    self.file = file
    self.line = line
  }

  public enum Reason {
    case noLabel
    case unsupportedType
    case memberTypeNotFound
    case parsingFailed
    case noFunctionFound
  }
}

extension ParseError: CustomStringConvertible {
  public var description: String {
    "\(reason) \(file):\(line)" // :: \(expr.description)"
  }
}

extension ParseError: LocalizedError {
  public var errorDescription: String? {
    description
  }
}
