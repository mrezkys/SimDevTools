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
    
    public var localizedDescription: String {
        switch self {
        case .noDevicesAreBooted:
            return "No devices are currently booted in the simulator."
        case .commandFailed(let message):
            return "The simctl command failed: \(message)"
        case .plistParsing(let details):
            return "Failed to parse simulator plist: \(details)"
        case .binaryNotFound(let path):
            return "Simulator binary not found at path: \(path)"
        case .utf8Decoding:
            return "The simulator output could not be decoded as UTF-8."
        }
    }
}
