//
//  Effect.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

public struct Effect<Intent> {
    public let run: () async -> Intent?
    
    public init(_ run: @escaping () async -> Intent?) {
        self.run = run
    }
    
    public static var none: Effect { .init{nil} }
    
    public static func fire(_ work: @escaping () async -> Void) -> Effect {
        .init {
            await work()
            return nil
        }
    }
}
