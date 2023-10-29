//
//  swift_demangle.swift
//
//
//  Created by Tomas Harkema on 28/10/2023.
//

import Darwin

// swiftlint:disable:next type_name
typealias swift_demangle_c = @convention(c) (
  _ mangledName: UnsafePointer<UInt8>?,
  _ mangledNameLength: Int,
  _ outputBuffer: UnsafeMutablePointer<UInt8>?,
  _ outputBufferSize: UnsafeMutablePointer<Int>?,
  _ flags: UInt32
) -> UnsafeMutablePointer<Int8>?

func swift_demangle(_ mangled: String) -> String? {
  let RTLD_DEFAULT = dlopen(nil, RTLD_NOW)
  if let sym = dlsym(RTLD_DEFAULT, "swift_demangle") {
    let f = unsafeBitCast(sym, to: swift_demangle_c.self)
    if let cString = f(mangled, mangled.count, nil, nil, 0) {
      defer { cString.deallocate() }
      return String(cString: cString)
    }
  }
  return nil
}
