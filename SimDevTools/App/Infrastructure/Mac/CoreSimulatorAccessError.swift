//
//  CoreSimulatorAccessError.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//

import Foundation

public enum CoreSimulatorAccessError: Error, Equatable {
    case noBookmark
    case staleBookmark
    case userCancelled
    case startScopedAccessFailed
    case bookmarkCreateFailed(String)
}
