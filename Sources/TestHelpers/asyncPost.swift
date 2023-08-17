//
//  asyncPost.swift
//  TestHelpers
//
//  Created by Tomas Harkema on 15/08/2023.
//  Copyright © 2023 Flitsmeister B.V. All rights reserved.
//

import Foundation
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

    @nonobjc func asyncPost(_ notification: String, object: Any? = nil, _ center: NotificationCenter = NotificationCenter.default) async {
        await asyncPost(.init(notification), object: object, center)
    }

    @nonobjc func asyncPost(_ notification: Notification.Name, object: Any? = nil, _ center: NotificationCenter = NotificationCenter.default) async {
        await asyncPost(.name(notification), object: object, center)
    }

    @nonobjc func asyncPost(_ notification: NotificationPost, object: Any? = nil, _ center: NotificationCenter = NotificationCenter.default) async {
        var handler: () -> () = {}
        var notificationHandler: NSObjectProtocol?

        switch notification {
        case .name(let name):
            notificationHandler = center.addObserver(name, object: object) { _ in
                handler()
                notificationHandler = nil
                handler = {}
            }
        case .object(let notificationObject):
            notificationHandler = center.addObserver(notificationObject.name, object: object) { _ in
                handler()
                notificationHandler = nil
                handler = {}
            }
        }

        Task { @MainActor in
            switch notification {
            case .name(let name):
                center.post(name, object: object)
            case .object(let object):
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

    @nonobjc func asyncPost<Payload>(_ payloaded: NotificationWithPayload<Payload>, payload: Payload) async {
        await asyncPost(.object(payloaded.notification(payload: payload)))
    }
}
