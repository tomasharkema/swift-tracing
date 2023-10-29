//
//  Settings.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation

public struct RuntimeWarnings: OptionSet {
  public static let calledOnMainThread = RuntimeWarnings(rawValue: 1 << 0)
  public static let noPreviousCaller = RuntimeWarnings(rawValue: 1 << 1)
  public static let notFromAnEntry = RuntimeWarnings(rawValue: 1 << 2)
  public static let printComingFromThread = RuntimeWarnings(rawValue: 1 << 3)
  public static let allowMainThreadWithoutEntryNoMainActor = RuntimeWarnings(rawValue: 1 << 4)

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

public enum Settings {
  public static var runtimeWarnings: RuntimeWarnings = [
    .calledOnMainThread, .notFromAnEntry, .printComingFromThread,
    .allowMainThreadWithoutEntryNoMainActor,
  ]
}
