import Foundation

struct EagerChain<LazyContainerType>: Encodable where LazyContainerType: Encodable {
  let coder: LazyContainerType

  init(_ coder: LazyContainerType) throws {
    self.coder = coder
  }

  var json: String {
    get throws {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
      let data = try encoder.encode(self)
      return String(data: data, encoding: .utf8) ?? ""
    }
  }

  func encode(to encoder: any Encoder) throws {
    try coder.encode(to: encoder)
  }
}
