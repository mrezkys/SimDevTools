//
//  oreSimulatorFilesystem.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//

import Foundation

protocol CoreSimulatorFilesystem {
    func findAppContainer(coreSimRoot: URL, bundleId: String) throws -> URL
    func readUserDefaults(coreSimRoot: URL, bundleId: String) throws -> [String: Any]
    func writeUserDefaults(coreSimRoot: URL, bundleId: String, key: String, value: Any) throws
}
