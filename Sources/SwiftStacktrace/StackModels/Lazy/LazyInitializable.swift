import Foundation

public protocol LazyInitializable: AnyObject {
  associatedtype InitializedType

  var initialized: InitializedType { get }
}

extension Array where Element: LazyInitializable {
  var initialized: [Element.InitializedType] {
    map(\.initialized)
  }
}

extension LazyInitializable where InitializedType: CustomStringConvertible {
  var description: String {
    initialized.description
  }
}

extension LazyInitializable where InitializedType: CustomDebugStringConvertible {
  var debugDescription: String {
    initialized.debugDescription
  }
}

extension LazyInitializable where InitializedType: CustomBriefStringConvertible {
  var briefDescription: String {
    initialized.briefDescription
  }
}

public extension LazyInitializable where InitializedType: Encodable {
  // init(from decoder: any Decoder) throws {
//     let value = try InitializedType(from: decoder)
//     self.initialized = value
//   }

  func encode(to encoder: any Encoder) throws {
    try initialized.encode(to: encoder)
  }
}
