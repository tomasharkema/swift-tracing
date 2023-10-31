//
//  Partial.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

public struct Partial: Attributable {
  private var value: String

  public init(_ value: String) {
    self.value = value // .escaped
  }
}

public protocol PartialStringConvertible {
  var line: String { get }
}

extension Partial: PartialStringConvertible {
  public var line: String {
    value
  }
}

@resultBuilder
public enum PartialBuilder {
  public typealias Expression = PartialStringConvertible

  public typealias Component = [any PartialStringConvertible]

  public static func buildExpression(_ expression: String) -> Component {
    [Partial(expression)]
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
