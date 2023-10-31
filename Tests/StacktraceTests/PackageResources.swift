import Foundation

extension PackageResources {
  static var lines: [String] {
    get throws {
      try JSONDecoder().decode([String].self, from: Data(PackageResources.lines_json))
    }
  }
}
