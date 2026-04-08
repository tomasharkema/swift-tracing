import Foundation

extension Result: @retroactive Encodable where Success: Encodable {
  public func encode(to encoder: any Encoder) throws {
    switch self {
    case .success(let encodable):
      try encodable.encode(to: encoder)
    case .failure(let error):
      var enc = encoder.singleValueContainer()
      try enc.encode(String(describing: error))
    }
  }
}
