//
//  StringBuilder.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

func flatten(in element: any StringConvertible) -> [any StringConvertible] {
  if let array = element as? [any StringConvertible] {
    let res = array.flatMap {
      flatten(in: $0)
    }
    return res
  } else {
    return [element]
  }
}

extension [any StringConvertible]: StringConvertible {
  public var lines: [String] {
    let strings = flatMap { element in
      let stringValue = element.lines
      return stringValue
    }
    return strings
  }
}

@resultBuilder
public enum StringBuilder {
  public typealias Expression = StringConvertible

  public typealias Component = [any StringConvertible]

  public static func buildExpression(_ expression: String) -> Component {
    [Text(expression)]
  }

  public static func buildExpression(_ expression: [any Expression]) -> Component {
    expression
  }

  public static func buildExpression(_ expression: any Expression) -> Component {
    [expression]
  }

  public static func buildBlock(_ components: Component...) -> Component {
    components
      .flatMap {
        $0
      }
  }

  public static func buildOptional(_ component: Component?) -> Component {
    component ?? []
  }

  public static func buildEither(first component: Component) -> Component {
    component
  }

  public static func buildEither(second component: Component) -> Component {
    component
  }

  public static func buildArray(_ components: [Component]) -> Component {
    components
      .flatMap {
        $0
      }
  }
}
