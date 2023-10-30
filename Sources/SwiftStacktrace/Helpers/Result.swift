import Foundation

extension Result: Encodable where Success: Encodable {
  public func encode(to encoder: any Encoder) throws {
    switch self {
    case let .success(encodable):
      try encodable.encode(to: encoder)
    case let .failure(error):
      var enc = encoder.singleValueContainer()
      try enc.encode(String(describing: error))
    }
  }
}
