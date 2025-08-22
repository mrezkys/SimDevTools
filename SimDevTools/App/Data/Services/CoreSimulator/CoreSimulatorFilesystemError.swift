//
//  CoreSimulatorFilesystemError.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//


import Foundation

public enum CoreSimulatorFilesystemError: Error, Equatable {
    case containerNotFound(bundleId: String)
    case plistNotDictionary
    case io(String)
}