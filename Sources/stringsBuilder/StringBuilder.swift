//
//  StringBuilder.swift
//  
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

package struct StringResult {
  package let strings: () -> [String]

  package var final: String {
    let str = strings()
    let res = str.joined(separator: "\n")
    return res
  }

  package func map(_ transform: @escaping (String) -> String) -> StringResult {
    StringResult {
      let str = strings()
      let value = str.map {
        transform($0)
      }
      return value
    }
  }
}

package struct Line {
  private let string: () -> String

  package init(
    _ string: @autoclosure @escaping () -> String
  ) {
    self.string = {
      let str = string()
      return "\(str)\n"
    }
  }

  package func stringElement() -> StringResult {
    StringResult {
      let str = string()
      return [str]
    }
  }
}

@resultBuilder
package struct StringBuilder {

  package static func buildExpression(_ expression: String) -> StringResult {
    StringResult {
      [expression]
    }
  }

  package static func buildExpression(_ expression: StringResult) -> StringResult {
    expression
  }

  package static func buildExpression(_ expression: IndentedResult) -> StringResult {
    return StringResult {
      let fn = expression.strings
      return fn(expression.char!)
    }
  }

  package static func buildExpression(_ expression: Indented) -> StringResult {
    let res = StringResult {
      let char = expression.char
      let strings = expression.result(char).strings
      let res = strings(char)
      return res
    }
    return res
  }

  package static func buildBlock(_ parts: StringResult) -> StringResult {
    return parts
  }

  package static func buildBlock(_ parts: StringResult...) -> StringResult {
    return StringResult {
      let elements = parts.flatMap {
        let res = $0.strings()
        return res
      }
      return elements
    }
  }

  package static func buildEither(first component: StringResult) -> StringResult {
    return component
  }
  
  package static func buildEither(second component: StringResult) -> StringResult {
    return component
  }

  package static func buildArray(_ components: [StringResult]) -> StringResult {
    let res = StringResult {
      let strings = components
        .flatMap {
          let res = $0.strings()
          return res
        }
      return strings
    }
    return res
  }

  package static func buildOptional(_ component: (StringResult)?) -> StringResult {
    if let component {
      return component
    } else {
      let res = StringResult {
        []
      }
      return res
    }
  }
}
