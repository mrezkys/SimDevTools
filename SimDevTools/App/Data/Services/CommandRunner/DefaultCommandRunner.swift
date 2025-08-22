//
//  CommandRunner.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

public struct DefaultCommandRunner: CommandRunnerProtocol {
    public init() {}
    public func run(_ launchPath: String, _ args: [String], env: [String : String]?) async throws -> CommandResult {
        guard FileManager.default.isExecutableFile(atPath: launchPath) else {
            throw SimulatorError.binaryNotFound(launchPath)
        }
        let p = Process()
        let out = Pipe(), err = Pipe()
        p.executableURL = URL(fileURLWithPath: launchPath)
        p.arguments = args
        p.standardOutput = out
        p.standardError = err
        if let env { p.environment = env }
        try p.run()
        p.waitUntilExit()
        let status = p.terminationStatus
        let stdout = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return CommandResult(stdOut: stdout, stdErr: stderr, status: status)
    }
}
