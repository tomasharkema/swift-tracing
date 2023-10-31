//
//  Text.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

public struct Text: Attributable {
  private var value: String

  public init(_ value: String) {
    self.value = value
  }
}

extension Text: StringConvertible {
  public var lines: [String] {
    [value]
  }
}
