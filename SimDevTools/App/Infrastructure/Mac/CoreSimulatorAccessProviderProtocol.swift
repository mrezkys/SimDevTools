//
//  CoreSimulatorAccessProviderProtocol.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//

import Foundation

public protocol CoreSimulatorAccessProviding {
    func coreSimRootURL() throws -> URL
    func requestCoreSimRootIfNeeded() throws -> URL
    func withCoreSimRoot<T>(_ body: (URL) throws -> T) throws -> T
}

