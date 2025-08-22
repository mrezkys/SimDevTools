//
//  SimulatorServiceProtocol.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

public protocol SimulatorServiceProtocol {
    func getBootedAppBundleIDs() async throws -> [String]
    func getAppContainerPath(for bundleID: String) async throws -> String
    func openURL(_ url: URL) async throws
}
