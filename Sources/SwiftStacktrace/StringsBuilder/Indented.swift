//
//  Indented.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

//public func Indented(
//  @IndentedBuiler _ makeResult: () -> IndentedResult
//) -> IndentedResult {
//  makeResult()
//}

public struct Indented {
  public var char: String
  public let result: () -> IndentedResult

  public init(_ char: String = "  ", @IndentedBuiler _ makeResult: @escaping () -> IndentedResult) {
    self.char = char
    self.result = {
      var result = makeResult()
      if result.char == nil {
        result.char = char
      }
      return result
    }
  }
}

public struct IndentedResult {
  public var char: String?
  public let strings: (String?) -> [String]

  public init(_ char: String? = nil, _ strings: @escaping (String?) -> [String]) {
    self.char = char
    self.strings = strings
  }

  public var final: [String] {
    let str = strings(char!)
    let finalString = str.map {
      "\(char!)\($0)"
//      "1 \($0)"
//      "├─ \($0)"
//      "  \($0)"
    }
    return finalString
  }

  public func map(_ transform: @escaping (String) -> String) -> IndentedResult {
    return IndentedResult(char) { char in
      let stri = strings(char).map {
        transform($0)
      }
      return stri
    }
  }
}


@resultBuilder
public struct IndentedBuiler {

  public static func buildExpression(_ expression: String) -> IndentedResult {
    return IndentedResult { _ in
      [expression]
    }
  }

  public static func buildExpression(_ expression: Indented) -> IndentedResult {
    let res = expression.result()
    return res
  }

  public static func buildExpression(_ expression: IndentedResult) -> IndentedResult {
//    let indent = expression.map {
////      "3 \($0)"
//      $0
//    }
//    return indent
    return expression
  }

  public static func buildExpression(_ expression: StringResult) -> IndentedResult {
    return IndentedResult { char in
      //("4 ") {
//      let indent = expression.map {
////        "\($0)"
//        //      "─ \($0)"
//        //      "\t\($0)"
//          "5 \($0)"
//      }
//      let res = indent.strings()
//      return res
      let indent = expression.map {
        "\(char!)\($0)"
      }
      let res = indent.strings()
      return res
    }
  }

  public static func buildBlock(_ parts: IndentedResult) -> IndentedResult {
    return parts
  }

  public static func buildBlock(_ parts: IndentedResult...) -> IndentedResult {
    return IndentedResult(nil) { backupChar in
      let elements = parts.flatMap { part in
        let char = part.char ?? backupChar
        let str = part.strings(char)
        let result = str.map {
          "\(char!)\($0)"
//          "5 \($0)"
          //        "─ \($0)"
          //        "\t\($0)"
//          "  \($0)"
        }
        return result
      }
      return elements
    }
  }

  public static func buildEither(first component: IndentedResult) -> IndentedResult {
    return component
  }

  public static func buildEither(second component: IndentedResult) -> IndentedResult {
    return component
  }

  public static func buildArray(_ components: [IndentedResult]) -> IndentedResult {
    return IndentedResult(nil) { _ in
      let finalize = components.flatMap { comp in
        let char = comp.char
        let element = comp.map { line in
          "\(comp.char!)\(line)"
        }
        return element.strings(char!)
        //      "─ \($0)"
        //      "\t\($0)"
//        "  \($0)"
      }
      return finalize
    }
  }

  public static func buildOptional(_ component: (IndentedResult)?) -> IndentedResult {
    if let component {
      return component
    } else {
      return IndentedResult("9 ") { _ in
        []
      }
    }
  }
}
