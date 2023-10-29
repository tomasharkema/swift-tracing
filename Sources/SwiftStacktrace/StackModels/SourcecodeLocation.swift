
public protocol SourcecodeLocation {
  var file: String { get }
  var line: UInt { get }
  var function: String { get }
  var moduleName: String { get }
}

public extension SourcecodeLocation {
  var shortFunctionName: String {
    guard #available(iOS 17, macOS 13, *) else {
      return function
    }

    let shortFunctionRegex = /\(([a-zA-Z:_]*)\)/

    let shortFunction = function.replacing(shortFunctionRegex) { _ in
      "(...)"
    }

    return shortFunction
  }

  var briefDescription: String {
    "\(shortFunctionName) - \(file):\(line) \(moduleName)"
  }

  var debugDescription: String {
    "\(function) - \(file):\(line) \(moduleName)"
  }
}
