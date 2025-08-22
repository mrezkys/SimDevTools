//
//  Reducer.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

public protocol Reducer {
    associatedtype State
    associatedtype Intent
    
    mutating func reduce(state: inout State, intent: Intent) -> [Effect<Intent>]
}
