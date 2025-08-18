//
//  SimulatorHelper.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import Foundation

enum SimulatorHelperError: Error {
    case processFailed(String)
    case dataConversionFailed
    case plistParsingFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .processFailed(let message):
            return "Process failed: \(message)"
        case .dataConversionFailed:
            return "Data conversion failed."
        case .plistParsingFailed(let message):
            return "Plist parsing failed: \(message)"
        }
    }
}


struct SimulatorHelper {
    static func getBootedSimulatorApps() -> Result<[String], SimulatorHelperError> {
        let process = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "listapps", "booted"]
        process.standardOutput = pipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            return .failure(.processFailed("Failed to start process: \(error.localizedDescription)"))
        }

        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            return .failure(.processFailed("Error: \(errorOutput)"))
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let outputString = String(data: data, encoding: .utf8) else {
            return .failure(.dataConversionFailed)
        }
        
        guard let plistData = outputString.data(using: .utf8) else {
            return .failure(.dataConversionFailed)
        }
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        do {
            if let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: &format) as? [String: Any] {
                let bundleIdentifiers = Array(plist.keys).sorted()
                return .success(bundleIdentifiers)
            } else {
                return .failure(.plistParsingFailed("Failed to parse plist data"))
            }
        } catch {
            return .failure(.plistParsingFailed("Error parsing plist: \(error.localizedDescription)"))
        }
    }
    
    static func fetchSimulatorPath(for bundleIdentifier: String) -> Result<String, SimulatorHelperError> {
        let process = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "get_app_container", "booted", bundleIdentifier, "data"]
        process.standardOutput = pipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            return .failure(.processFailed("Failed to start process: \(error.localizedDescription)"))
        }

        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            return .failure(.processFailed("Error: \(errorOutput)"))
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return .success(output.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            return .failure(.dataConversionFailed)
        }
    }

    static func openURLInSimulator(url: String) -> Result<Void, SimulatorHelperError> {
        let process = Process()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "openurl", "booted", url]
        process.standardError = errorPipe
        
        do {
            try process.run()
        } catch {
            return .failure(.processFailed("Failed to start process: \(error.localizedDescription)"))
        }

        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            return .failure(.processFailed("Failed to open URL in simulator: \(errorOutput)"))
        }
        
        return .success(())
    }
}
