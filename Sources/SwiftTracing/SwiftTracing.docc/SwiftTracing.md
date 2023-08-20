# ``SwiftTracing``

Trace code with `OSLog.OSSignposter`

## Overview

```swift
let signposter = Signposter(subsystem: "a", category: "b")

try await signposter.measureTask(withNewId: "A") {
    print("A")
    try await Task.sleep(for: .seconds(1))
    print("B")
}
```

## Topics

### Essentials

- ``Signposter``
- ``Signposter/measureTask(withNewId:_:)-3g7l3``
