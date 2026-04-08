//
//  List.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

public struct List: PartialStringConvertible {
  private let separator: String
  private let parts: [any PartialStringConvertible]

  public init(separator: String, @PartialBuilder _ handler: () -> [any PartialStringConvertible]) {
    self.separator = separator
    parts = handler()
  }

  public var line: String {
    parts.map(\.line).joined(separator: separator)
  }
}
