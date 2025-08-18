//
//  PermissionState.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import Foundation

enum PermissionState: String, Equatable {
    case granted = "granted"
    case denied = "denied"
    case readWrite = "read-write"
    case readOnly = "read-only"
    case always = "always"
    case inUse = "inuse"
    case never = "never"
    case notDetermined = "notDetermined"
    case limited = "limited"

    var displayName: String {
        switch self {
        case .granted:
            return "Granted"
        case .denied:
            return "Denied"
        case .readWrite:
            return "Read-Write"
        case .readOnly:
            return "Read-Only"
        case .always:
            return "Always"
        case .inUse:
            return "In Use"
        case .never:
            return "Never"
        case .notDetermined:
            return "Not Determined"
        case .limited:
            return "Limited"
        }
    }

    // Define available states for services like `photos`, `location`, and `contacts`
    static let grantRevokeResetStates: [PermissionState] = [.granted, .denied, .notDetermined]
    static let photosStates: [PermissionState] = [.readWrite, .readOnly, .denied, .notDetermined]
    static let locationStates: [PermissionState] = [.always, .inUse, .never, .notDetermined]
    static let contactsStates: [PermissionState] = [.granted, .limited, .denied, .notDetermined]

    static func defaultState(for serviceName: String) -> PermissionState {
        // Default state to `notDetermined` for all services
        return .notDetermined
    }
}
