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
        let devDir: String = {
            let p = Process(); let out = Pipe()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
            p.arguments = ["-p"]; p.standardOutput = out
            try? p.run(); p.waitUntilExit()
            if p.terminationStatus == 0,
               let s = String(data: out.fileHandleForReading.readDataToEndOfFile(),
                              encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               !s.isEmpty { return s }
            return "/Applications/Xcode.app/Contents/Developer"
        }()
        
        let simctl = "\(devDir)/usr/bin/simctl"
        guard FileManager.default.isExecutableFile(atPath: simctl) else {
            return .failure(.processFailed("simctl not found or not executable at \(simctl)"))
        }
        
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: simctl)
        process.arguments = ["listapps", "booted"]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        var env = ProcessInfo.processInfo.environment
        env["DEVELOPER_DIR"] = devDir
        process.environment = env
        
        do { try process.run() }
        catch {
            return .failure(.processFailed("Failed to start simctl: \(error.localizedDescription)"))
        }
        process.waitUntilExit()
        
        let status = process.terminationStatus
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        
        if status != 0 {
            let msg = stderr.isEmpty ? "simctl exited with status \(status)" : stderr
            return .failure(.processFailed(msg))
        }
        
        guard !stdout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .success([])
        }
        
        guard let plistData = stdout.data(using: .utf8) else {
            return .failure(.dataConversionFailed)
        }
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        do {
            let obj = try PropertyListSerialization.propertyList(from: plistData, options: [], format: &format)
            guard let dict = obj as? [String: Any] else {
                return .failure(.plistParsingFailed("Top-level object is not a dictionary"))
            }
            let bundleIDs = dict.keys.sorted()
            return .success(bundleIDs)
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
