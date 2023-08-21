//
//  asyncPost.swift
//  TestHelpers
//
//  Created by Tomas Harkema on 15/08/2023.
//  Copyright © 2023 Flitsmeister B.V. All rights reserved.
//

import Foundation
import SwiftTaskToolbox
#if canImport(XCTest)
import XCTest

public enum NotificationPost {
    case name(Notification.Name)
    case object(Notification)
}

public extension XCTestCase {
    @nonobjc func asyncYield() async {
        await Task.yield()
        let exp = expectation(description: "derp")
        Task {
            try? await Task.sleep(seconds: 1)
            exp.fulfill()
        }
        await fulfillment(of: [exp])
    }

    @nonobjc func asyncPost(
        _ notification: String,
        object: Any? = nil,
        _ center: NotificationCenter = NotificationCenter.default
    ) async {
        await asyncPost(.init(notification), object: object, center)
    }

    @nonobjc func asyncPost(
        _ notification: Notification.Name,
        object: Any? = nil,
        _ center: NotificationCenter = NotificationCenter.default
    ) async {
        await asyncPost(.name(notification), object: object, center)
    }

    @nonobjc func asyncPost(
        _ notification: NotificationPost,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        _ center: NotificationCenter = NotificationCenter.default
    ) async {
        var handler: () -> Void = {}
        var notificationHandler: NSObjectProtocol?

        switch notification {
        case let .name(name):
            notificationHandler = center.addObserver(forName: name, object: object, queue: queue) { _ in
                handler()
                notificationHandler = nil
                handler = {}
            }
        case let .object(notificationObject):
            notificationHandler = center.addObserver(forName: notificationObject.name, object: object, queue: queue) { _ in
                handler()
                notificationHandler = nil
                handler = {}
            }
        }

        Task { @MainActor in
            switch notification {
            case let .name(name):
                center.post(name: name, object: object)
            case let .object(object):
                center.post(object)
            }
        }
        await withCheckedContinuation { res in
            handler = {
                res.resume()
            }
        }
        await Task.yield()
    }
}

extension NotificationCenter: @unchecked Sendable {}
#endif
