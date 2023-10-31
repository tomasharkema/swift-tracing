//
//  Appending.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

public struct Appending: StringConvertible {
  private let parts: [any PartialStringConvertible]

  public init(@PartialBuilder _ handler: () -> [any PartialStringConvertible]) {
    parts = handler()
  }

  public var lines: [String] {
    [parts.map(\.line).joined(separator: " ")]
  }
}
