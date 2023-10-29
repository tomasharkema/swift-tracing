//
//  runtimeWarning.swift
//
//
//  Created by Tomas Harkema on 21/08/2023.
//

#if DEBUG
#if canImport(os)
import os
import SwiftUI

// NB: Xcode runtime warnings offer a much better experience than traditional assertions and
//     breakpoints, but Apple provides no means of creating custom runtime warnings ourselves.
//     To work around this, we hook into SwiftUI's runtime issue delivery mechanism, instead.
//
// Feedback filed: https://gist.github.com/stephencelis/a8d06383ed6ccde3e5ef5d1b3ad52bbc
let runtimeWarningDso = (
  dso: { () -> UnsafeMutableRawPointer in
    var info = Dl_info()
    dladdr(dlsym(dlopen(nil, RTLD_LAZY), "LocalizedString"), &info)
    return info.dli_fbase
  }(),
  log: OSLog(subsystem: "com.apple.runtime-issues", category: "SwiftTracing")
)

@_transparent
@inline(__always)
func runtimeWarning(
  _ string: StaticString,
  _ args: any CVarArg...
) {
  os_log(.fault, dso: runtimeWarningDso.dso, log: runtimeWarningDso.log, string, args)
}

#else
@_transparent
@inline(__always)
func runtimeWarning(
  _: StaticString,
  _: CVarArg...
) {}
#endif

#endif
