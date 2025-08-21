//
//  SimulatorHelper.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import Foundation

enum SimulatorHelperError: Error {
    case noDevicesAreBooted
    case processFailed(String)
    case dataConversionFailed
    case plistParsingFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .noDevicesAreBooted:
            return "No devices are booted"
        case .processFailed(let message):
            return "Process failed: \(message)"
        case .dataConversionFailed:
            return "Data conversion failed."
        case .plistParsingFailed(let message):
            return "Plist parsing failed: \(message)"
        }
    }
}

struct CommandResultModel {
    var stdOut: String;
    var stdErr: String;
    var status: Int32;
    
}

struct SimulatorHelper {
    static func execute(arguments: [String]) -> Result<CommandResultModel, SimulatorHelperError> {
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
        process.arguments = arguments
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
        
        return .success(CommandResultModel(stdOut: stdout, stdErr: stderr, status: status))
    }
    static func getBootedSimulatorApps() -> Result<[String], SimulatorHelperError> {
        var commandResult: CommandResultModel;
        switch execute(arguments: ["listapps", "booted"]) {
        case .success(let res):
            commandResult = res
        case .failure(let err):
            return .failure(err)
        }

        if commandResult.status != 0 {
            let msg = commandResult.stdErr.isEmpty ? "simctl exited with status \(commandResult.status)" : commandResult.stdErr
            if msg.lowercased().contains("no devices are booted") {
                return .failure(.noDevicesAreBooted)
            }
            return .failure(.processFailed(msg))
        }
        
        guard !commandResult.stdOut.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .success([])
        }
        
        guard let plistData = commandResult.stdOut.data(using: .utf8) else {
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
        var commandResult: CommandResultModel;
        switch execute(arguments: ["get_app_container", "booted", bundleIdentifier, "data"]) {
        case .success(let res):
            commandResult = res
        case .failure(let err):
            return .failure(err)
        }
        
        return .success(commandResult.stdOut.trimmingCharacters(in: .whitespacesAndNewlines))
        
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
