//
//  ContentHeaderMessageType.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 04/10/24.
//

import SwiftUI

enum ContentHeaderMessageType: Equatable {
    case error
    case success
    case general

    var backgroundColor: Color {
        switch self {
        case .error:
            return Color.red
        case .success:
            return Color.green
        case .general:
            return Color.blue
        }
    }

    var iconName: String {
        switch self {
        case .error:
            return "exclamationmark.triangle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .general:
            return "info.circle.fill"
        }
    }
}
