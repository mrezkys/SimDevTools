//
//  CommandRunner 2.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

public protocol CommandRunnerProtocol {
    func run(
        _ launchPath: String,
        _ args: [String],
        env: [String:String]?
    ) async throws -> CommandResult
}
