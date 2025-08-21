//
//  PushNotificationTemplate.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import Foundation

enum PushNotificationTemplate: String, CaseIterable, Identifiable {
    case basic = "Basic"
    case contentAvailable = "Content Available"
    case mutableContent = "Mutable Content"
    case customData = "Custom Data"

    var id: String { self.rawValue }

    var payload: String {
        switch self {
        case .basic:
            return """
            {
                "aps": {
                    "alert": "Helloooo, world!",
                    "badge": 1,
                    "sound": "default"
                }
            }
            """
        case .contentAvailable:
            return """
            {
                "aps": {
                    "content-available": 1
                }
            }
            """
        case .mutableContent:
            return """
            {
                "aps": {
                    "alert": "Hello, world!",
                    "mutable-content": 1
                }
            }
            """
        case .customData:
            return """
            {
                "aps": {
                    "alert": "Hello, world!"
                },
                "data": {
                    "itemID": "123456"
                }
            }
            """
        }
    }
}
