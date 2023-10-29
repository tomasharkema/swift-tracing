//
//  FrameRegex.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

import Foundation
import RegexBuilder

@available(iOS 16.0, macOS 13, *)
enum FrameRegex {
  static let indexRef = Reference(Int.self)
  static let libraryRef = Reference(Substring.self)
  static let stackPointerRef = Reference(Substring.self)
  static let mangledFuncRef = Reference(Substring.self)

  /// basically `/\S/`
  static let sentence: CharacterClass = .whitespace.inverted.subtracting(.newlineSequence)

  /// Parsing the following format:
  /// "6   libswift_Concurrency.dylib          0x00000001b1641d25
  /// $ss9TaskLocalC9withValue_9operation4file4lineqd__x_qd__yYaKXESSSutYaKlFTQ0_ + 1"
  static let frameRegex = Regex {
    TryCapture(as: indexRef) {
      OneOrMore(.digit)
    } transform: { match in
      Int(match)
    }

    OneOrMore(.whitespace)

    Capture(as: libraryRef) {
      OneOrMore(sentence)
    }

    OneOrMore(.whitespace)

    Capture(as: stackPointerRef) {
      OneOrMore(sentence)
    }

    OneOrMore(.whitespace)

    Capture(as: mangledFuncRef) {
      OneOrMore(sentence)
    }
  }
}
