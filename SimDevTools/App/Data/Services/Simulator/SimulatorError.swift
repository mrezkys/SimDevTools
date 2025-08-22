//
//  SimulatorServiceError.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

public enum SimulatorError: Error, Equatable {
    case noDevicesAreBooted
    case commandFailed(String)
    case plistParsing(String)
    case binaryNotFound(String)
    case utf8Decoding
    
    var isNoDevicesBooted: Bool {
        switch self {
        case .noDevicesAreBooted:
            return true
        default:
            return false
        }
    }
}
