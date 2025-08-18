//
//  PermissionModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import Foundation

struct Permission: Identifiable, Equatable {
    let id = UUID()
    let serviceName: String
    let displayName: String
    let availableStates: [PermissionState]
    var currentState: PermissionState = .notDetermined

    static func == (lhs: Permission, rhs: Permission) -> Bool {
        lhs.id == rhs.id
    }
}
