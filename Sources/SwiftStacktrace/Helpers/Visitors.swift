//
//  Visitors.swift
//
//
//  Created by Tomas Harkema on 29/10/2023.
//

import Foundation
import SwiftSyntax

final class FindFunctionWithExpression: SyntaxVisitor {
  private(set) var functionBlock: FunctionCallExprSyntax?

  override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
    guard functionBlock == nil else {
      assertionFailure()
      return .skipChildren
    }
    functionBlock = node
    return .skipChildren
  }
}

final class MemberTypeSyntaxWithExpression: SyntaxVisitor {
  private(set) var functionBlock: MemberTypeSyntax?

  override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
    guard functionBlock == nil else {
      assertionFailure()
      return .skipChildren
    }
    functionBlock = node
    return .skipChildren
  }
}
