//
//  SimulatorService.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

public final class SimulatorService: SimulatorServiceProtocol {
    private let runner: CommandRunnerProtocol
    private let devDir: String
    private let simctlPath: String
    private let xcrunPath: String = "/usr/bin/xcrun"

    public init(runner: CommandRunnerProtocol = DefaultCommandRunner(), devDir: String? = nil) {
        self.runner = runner
        let resolved = devDir ?? SimulatorService.resolveDeveloperDir()
        self.devDir = resolved
        self.simctlPath = "\(resolved)/usr/bin/simctl"
    }
    
    public func getBootedSimulators() async throws -> [BootedSimulator] {
        let env = ["DEVELOPER_DIR": devDir]
        let res = try await runner.run(
            simctlPath,
            ["list", "devices", "booted", "--json"],
            env: env
        )

        if res.status != 0 {
            throw mapSimctlError(stderr: res.stdErr, status: res.status)
        }

        struct DevicesResponse: Decodable {
            let devices: [String: [BootedSimulator]]
        }

        guard let data = res.stdOut.data(using: .utf8) else {
            throw SimulatorError.utf8Decoding
        }

        let decoded = try JSONDecoder().decode(DevicesResponse.self, from: data)

        let all = decoded.devices.values.flatMap { $0 }

        return all.filter { $0.state == "Booted" }
    }
    
    public func getAppBundleIDs(forUDID udid: String) async throws -> [String] {
        let env = ["DEVELOPER_DIR": devDir]
        let res = try await runner.run(simctlPath, ["listapps", udid], env: env)

        if res.status != 0 {
            throw mapSimctlError(stderr: res.stdErr, status: res.status)
        }

        let trimmed = res.stdOut.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let keys = try Plist.topLevelDictionaryKeys(fromUTF8: trimmed)
        return keys.sorted()
    }

    public func getBootedAppBundleIDs() async throws -> [String] {
        let env = ["DEVELOPER_DIR": devDir]
        let res = try await runner.run(simctlPath, ["listapps", "booted"], env: env)
        if res.status != 0 { throw mapSimctlError(stderr: res.stdErr, status: res.status) }
        let trimmed = res.stdOut.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let keys = try Plist.topLevelDictionaryKeys(fromUTF8: trimmed)
        return keys.sorted()
    }

    public func getAppContainerPath(for bundleID: String) async throws -> String {
        let env = ["DEVELOPER_DIR": devDir]
        let res = try await runner.run(simctlPath, ["get_app_container", "booted", bundleID, "data"], env: env)
        if res.status != 0 { throw mapSimctlError(stderr: res.stdErr, status: res.status) }
        return res.stdOut.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func openURL(_ url: URL) async throws {
        let res = try await runner.run(xcrunPath, ["simctl", "openurl", "booted", url.absoluteString], env: nil)
        if res.status != 0 {
            throw SimulatorError.commandFailed(res.stdErr.isEmpty ? "xcrun exited with \(res.status)" : res.stdErr)
        }
    }

    // MARK: - Helpers

    private func mapSimctlError(stderr: String, status: Int32) -> SimulatorError {
        let msg = stderr.isEmpty ? "simctl exited with status \(status)" : stderr
        if msg.lowercased().contains("no devices are booted") { return .noDevicesAreBooted }
        return .commandFailed(msg)
    }

    private static func resolveDeveloperDir() -> String {
        let p = Process(); let out = Pipe()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
        p.arguments = ["-p"]; p.standardOutput = out
        try? p.run(); p.waitUntilExit()
        if p.terminationStatus == 0,
           let s = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
             .trimmingCharacters(in: .whitespacesAndNewlines),
           !s.isEmpty { return s }
        return "/Applications/Xcode.app/Contents/Developer"
    }
}


public struct BootedSimulator: Codable, Equatable, Hashable, Identifiable {
    public var id: String { udid }
    public let udid: String
    public let name: String
    public let state: String
    public let isAvailable: Bool
    public let deviceTypeIdentifier: String
    public let lastBootedAt: String?
    public let dataPath: String?
    public let logPath: String?
}
