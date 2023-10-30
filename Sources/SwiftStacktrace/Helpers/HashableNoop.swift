@propertyWrapper
public struct HashableNoop<Value>: Hashable, Equatable {
  @EquatableNoop
  public var wrappedValue: Value

  public init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }

  public func hash(into _: inout Hasher) {}
}

extension HashableNoop: Encodable where Value: Encodable {
  public func encode(to encoder: any Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
}
