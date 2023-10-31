//
//  Indented.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Algorithms
import Foundation

public struct Indented: Attributable, StringConvertible {
  private let character: String
  public private(set) var partialResult: any StringConvertible

  /// Creates a text element that displays a string.
  ///
  /// - Parameters:
  ///   - value: The string to display.
  public init(character: String = "  ", @StringBuilder _ content: () -> any StringConvertible) {
    self.character = character
    let string = content()

    partialResult = string
  }

  public var lines: [String] {
    let flattened = flatten(in: partialResult)
    let eles = flattened.flatMap {
      let svalue = $0.lines
      let mapped = svalue.map {
        "\(character)\($0)"
      }
      return mapped
    }
    return eles
  }
}
