//
//  StorageFeatureError.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//

import Foundation

enum StorageFeatureError: Equatable, Error {
    case notConfigured
    case fs(CoreSimulatorFilesystemError)
    case writeFailed(String)
    case unknown(String)

    var message: String {
        switch self {
        case .notConfigured:
            return "You need to select an app bundle first in Configuration."
        case .fs(let e):
            switch e {
            case .containerNotFound(let b):   return "App container not found for \(b)."
            case .plistNotDictionary:         return "Preferences plist is not a dictionary."
            case .io(let s):                  return s
            }
        case .writeFailed(let s):
            return "Failed to write value: \(s)"
        case .unknown(let s):
            return s
        }
    }
}
