import Foundation

public protocol LazyContainer {
  associatedtype LazyType

  var lazy: LazyType { get }
}

extension Array where Element: LazyContainer {
  var lazy: [Element.LazyType] {
    map(\.lazy)
  }
}

extension LazyContainer where LazyType: LazyInitializable {
  var initialized: LazyType.InitializedType {
    lazy.initialized
  }
}

extension LazyContainer where LazyType: Encodable {
  func encode(to encoder: any Encoder) throws {
    try lazy.encode(to: encoder)
  }
}

// extension LazyContainer where LazyType: LazyInitializable, LazyType.InitializedType: Encodable {
//     func encode(to encoder: any Encoder) throws {
//         try lazy.initialized.encode(to: encoder)
//     }
// }
