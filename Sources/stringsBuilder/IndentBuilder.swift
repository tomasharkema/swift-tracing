//
//  IndentBuilder.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

package struct Indented {
  package var char: String
  package let result: (String?) -> IndentedResult

  package init(
    _ charInput: String = "  ",
    @IndentedBuiler _ makeResult: @escaping () -> IndentedResult
  ) {
    char = charInput
    result = { charPassthrough in
      var result = makeResult()
      if let charPassthrough, result.char == nil {
        result.char = charPassthrough
      }
      return result
    }
  }
}

package struct IndentedResult {
  package var char: String?
  package let strings: (String?) -> [String]

  package init(_ char: String? = nil, _ strings: @escaping (String?) -> [String]) {
    self.char = char
    self.strings = strings
  }

  package var final: [String] {
    let str = strings(char!)
    let finalString = str.map {
      "\(char!)\($0)"
    }
    return finalString
  }

  package func map(_ transform: @escaping (String) -> String) -> IndentedResult {
    IndentedResult(char) { char in
      let stri = strings(char).map {
        transform($0)
      }
      return stri
    }
  }
}

@resultBuilder
package enum IndentedBuiler {
  package static func buildExpression(_ expression: String) -> IndentedResult {
    IndentedResult { _ in
      [expression]
    }
  }

  package static func buildExpression(_ expression: Indented) -> IndentedResult {
    let res = IndentedResult { backup in
      let element = expression.result(backup)
      let trans = element.map { str in
        "\(backup ?? "")\(str)"
      }
      let ress = trans.strings(expression.char)
      return ress
    }
    return res
  }

  package static func buildExpression(_ expression: IndentedResult) -> IndentedResult {
    expression
  }

  package static func buildExpression(_ expression: StringResult) -> IndentedResult {
    let res = IndentedResult { char in
      let indent = expression.map {
        "\(char!)\($0)"
      }
      let res = indent.strings()
      return res
    }
    return res
  }

  package static func buildBlock(_ parts: IndentedResult) -> IndentedResult {
    let res = IndentedResult { char in
      let strings = parts.strings(char)
      return strings
    }
    return res
  }

  package static func buildBlock(_ parts: IndentedResult...) -> IndentedResult {
    let res = IndentedResult(nil) { backupChar in
      let elements = parts.flatMap { part in
        let str = part.strings(part.char)
        let result = str.map {
          "\(backupChar!)\($0)"
        }
        return result
      }
      return elements
    }
    return res
  }

  package static func buildEither(first component: IndentedResult) -> IndentedResult {
    component
  }

  package static func buildEither(second component: IndentedResult) -> IndentedResult {
    component
  }

//  package static func buildArray(_ components: [IndentedResult]) -> IndentedResult {
//    return IndentedResult(nil) { _ in
//      let finalize = components.flatMap { comp in
//        let char = comp.char
//        let element = comp.map { line in
//          "\(comp.char!)\(line)"
//        }
//        return element.strings(char!)
//        //      "─ \($0)"
//        //      "\t\($0)"
  ////        "  \($0)"
//      }
//      return finalize
//    }
//  }

  package static func buildOptional(_ component: IndentedResult?) -> IndentedResult {
    if let component {
      component
    } else {
      IndentedResult("9 ") { _ in
        []
      }
    }
  }
}
