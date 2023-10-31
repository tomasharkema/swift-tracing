//
//  StringBuilder.swift
//  
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

public struct StringResult {
  public let strings: () -> [String]

  public var final: String {
    let str = strings()
    let res = str.joined(separator: "\n")
    return res
  }

  public func map(_ transform: @escaping (String) -> String) -> StringResult {
    StringResult {
      let str = strings()
      let value = str.map {
        transform($0)
      }
      return value
    }
  }
}

public struct Line {
  private let string: () -> String

  public init(
    _ string: @autoclosure @escaping () -> String
  ) {
    self.string = {
      let str = string()
      if str.hasSuffix("\n") {
        assertionFailure()
      }
      return "\(str)\n"
    }
  }

  public func stringElement() -> StringResult {
    StringResult {
      let str = string()
      return [str]
    }
  }
}

@resultBuilder
public struct StringBuilder {

  public static func buildExpression(_ expression: String) -> StringResult {
    StringResult {
      [expression]
    }
  }

  public static func buildExpression(_ expression: StringResult) -> StringResult {
    expression
  }

  public static func buildExpression(_ expression: IndentedResult) -> StringResult {
    return StringResult {
      let fn = expression.strings
      return fn(expression.char!)
    }
  }

  public static func buildExpression(_ expression: Indented) -> StringResult {
    return StringResult {
      let char = expression.char
      let strings = expression.result().strings
      let res = strings(char)
      return res
    }
  }

  public static func buildBlock(_ parts: StringResult) -> StringResult {
    return parts
  }

  public static func buildBlock(_ parts: StringResult...) -> StringResult {
    return StringResult {
      let elements = parts.flatMap {
        let res = $0.strings()
        return res
      }
      return elements
    }
  }

  public static func buildEither(first component: StringResult) -> StringResult {
    return component
  }
  
  public static func buildEither(second component: StringResult) -> StringResult {
    return component
  }

  public static func buildArray(_ components: [StringResult]) -> StringResult {
    return StringResult {
      let strings = components
        .flatMap {
          let res = $0.strings()
          return res
        }
      return strings
    }
  }

  public static func buildOptional(_ component: (StringResult)?) -> StringResult {
    if let component {
      return component
    } else {
      return StringResult {
        []
      }
    }
  }
}
