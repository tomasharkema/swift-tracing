import Foundation

extension Bundle {
  var lines: [String] {
    get throws {
      let url = url(forResource: "lines", withExtension: "json")!
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode([String].self, from: data)
    }
  }
}
