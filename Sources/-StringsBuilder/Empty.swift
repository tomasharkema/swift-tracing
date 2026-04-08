//
//  Empty.swift
//
//
//  Created by Tomas Harkema on 31/10/2023.
//

import Foundation

public struct Empty: StringConvertible {
  public let lines: [String] = [" "]
  public init() {}
}
