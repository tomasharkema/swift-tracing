//
//  FunctionInfo.swift
//
//
//  Created by Tomas Harkema on 29/10/2023.
//

import Foundation
import SwiftParser
import SwiftSyntax

public struct FunctionInfo: Hashable, Equatable, Sendable, CustomDebugStringConvertible {
  let functionType: TypeName?
  let functionName: String
//  let functionGenerics: String?
//
//  let arguments: String?
//  let asyncToken: String?
//  let throwsToken: String?
//  let returnTypeLib: String?
//  let returnType: String?
//
//  let extraPrefix: String?
//  let extraSuffix: String?

  let arguments: [FunctionArgument]

  let raw: String

  package init(_ line: String) throws {
    guard #available(macOS 13, *) else {
      throw NSError(domain: "", code: 0)
    }

    self.raw = line
    let sourceFile: SourceFileSyntax = Parser.parse(source: line)

    let isSucceded = line == sourceFile.description

    guard isSucceded else {
      throw FunctionInfoError(expr: sourceFile, reason: .parsingFailed)
    }

    let findFunction = FindFunctionWithExpression(viewMode: .sourceAccurate)
    findFunction.walk(sourceFile)

    guard let functionBlock = findFunction.functionBlock else {
      throw FunctionInfoError(expr: sourceFile, reason: .noFunctionFound)
    }

    print("vvv")
    dump(functionBlock)
    print("^^^")
    print("vvv")
    print(functionBlock)
    print("^^^")

    guard let memberAccessExpr = functionBlock.calledExpression.as(MemberAccessExprSyntax.self)
    else {
      throw FunctionInfoError(expr: functionBlock, reason: .memberTypeNotFound)
    }

    let base = memberAccessExpr.base?.as(MemberAccessExprSyntax.self)

    functionType = try base.map { try TypeName($0) }
    functionName = memberAccessExpr.declName.description

//    let arguments = functionBlock.arguments.map { argument in
//      let typeExpression = argument.expression.as(MemberAccessExprSyntax.self)
//      let name = argument.label?.text ?? ""
//      let typeBase = typeExpression?.base?.description ?? ""
//      let typeName = typeExpression?.declName.baseName.description ?? ""
//      let type = TypeName(base: typeBase, name: typeName)
//      return FunctionArgument(label: name, typeName: type)
//    }

    let arguments = try functionBlock.arguments.compactMap { argument in
      try FunctionArgument(argument)
    }

    print(arguments)
    dump(arguments)

    self.arguments = arguments
  }

  public var debugDescription: String {
    raw //"\(functionType?.debugDescription ?? "") \(functionName) \(arguments)"
  }
}

public extension FunctionInfo {
  struct FunctionArgument: Hashable, Equatable, Sendable, CustomDebugStringConvertible {
    let label: String?
    let type: TypeName

    init(label: String?, type: TypeName) {
      self.label = label
      self.type = type
    }

    init(_ decl: LabeledExprSyntax) throws {
      label = decl.label?.text

      let type = try TypeName(decl.expression)
      self.type = type
    }

    public var debugDescription: String {
      "\(label ?? "") \(type)"
    }
  }
}

public extension FunctionInfo {
  struct TypeName: Hashable, Equatable, Sendable, CustomDebugStringConvertible {
    let base: String?
    let name: String

    init(base: String?, name: String) {
      self.base = base
      self.name = name
    }

    init(_ expr: ExprSyntax) throws {
      if let memberExpr = expr.as(MemberAccessExprSyntax.self) {
        try self.init(memberExpr)
      } else if let sequenceExpr = expr.as(SequenceExprSyntax.self) {
        try self.init(sequenceExpr)
      } else {
        throw FunctionInfoError(expr: expr, reason: .noLabel)
      }
    }

    init(_ expr: MemberAccessExprSyntax) throws {
      base = expr.base?.description
      name = expr.declName.baseName.description
    }

    init(_ expr: SequenceExprSyntax) throws {
      dump(expr.elements)

      let finder = MemberTypeSyntaxWithExpression(viewMode: .sourceAccurate)
      finder.walk(expr)

      guard let memberType = finder.functionBlock else {
        throw FunctionInfoError(expr: expr, reason: .memberTypeNotFound)
      }

      base = memberType.baseType.description
      name = memberType.name.text
    }

    public var debugDescription: String {
      "\(base ?? "") \(name)"
    }
  }
}

public struct FunctionInfoError: Error {
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

// swiftlint:disable:next type_name
struct _FunctionInfo: Hashable, Equatable, Sendable {
  let awaitToken: String?
  let resumeToken: String?
  let partialToken: String?
  let functionToken: String?
  let forToken: String?
  let staticToken: String?

  let libName: String?
  let typeName: String?
  let functionName: String?
  let functionGenerics: String?

  let arguments: String?
  let asyncToken: String?
  let throwsToken: String?
  let returnTypeLib: String?
  let returnType: String?

  let extraPrefix: String?
  let extraSuffix: String?

  init?(_ line: String) {
    guard #available(macOS 13.0, *) else {
      return nil
    }

    let regex = // swiftlint:disable:next line_length
      /((?<awaitToken>await) )?((?<resumeToken>resume) )?((?<partialToken>partial) )?((?<functionToken>function) )?((?<forToken>for) )?((?<staticToken>static) )?((?<libName>[a-zA-Z]+).)?((?<typeName>[a-zA-Z]+).)?(?<functionName>[a-zA-Z$]+)(?<functionGenerics><[a-zA-Z:. ]+>)?\((?<arguments>.*)\) ((?<asyncToken>async ))?((?<throwsToken>throws ))?-> ((?<returnTypeLib>[a-zA-Z]+).)?(?<returnType>[a-zA-Z]+)?/

    guard let tokens = line.firstMatch(of: regex) else {
      assertionFailure()
      return nil
    }

    awaitToken = tokens.output.awaitToken.map { String($0) }
    resumeToken = tokens.output.resumeToken.map { String($0) }
    partialToken = tokens.output.partialToken.map { String($0) }
    functionToken = tokens.output.functionToken.map { String($0) }
    forToken = tokens.output.forToken.map { String($0) }
    staticToken = tokens.output.staticToken.map { String($0) }

    libName = tokens.output.libName.map { String($0) }
    typeName = tokens.output.typeName.map { String($0) }
    functionName = String(tokens.output.functionName) // .map { String($0) }
    functionGenerics = tokens.output.functionGenerics.map { String($0) }

    arguments = String(tokens.output.arguments) // .map { String($0) }
    asyncToken = tokens.output.asyncToken.map { String($0) }
    throwsToken = tokens.output.throwsToken.map { String($0) }
    returnTypeLib = tokens.output.returnTypeLib.map { String($0) }
    returnType = tokens.output.returnType.map { String($0) }

    extraPrefix = String(line.prefix(upTo: tokens.range.lowerBound))
    extraSuffix = String(line.suffix(from: tokens.range.upperBound))

    print(line, self)
    print(self)
    print(self)
  }
}
