import Foundation
import SnapshotTesting

func assertSnapshot(
  of string: String,
  record: Bool = false,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  assertSnapshot(
    of: string.split(separator: "\n"), as: .dump, record: record, 
    file: file, testName: testName, line: line
  )
}
