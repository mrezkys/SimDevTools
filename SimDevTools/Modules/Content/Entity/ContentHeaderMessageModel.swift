//
//  ContentHeaderMessageModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 04/10/24.
//

import Foundation

struct ContentHeaderMessageModel: Equatable {
    let text: String
    let type: ContentHeaderMessageType
    
    static func getLoadingMessage(for featureName: String) -> Self {
        return .init(text: "Loading (\(featureName))...", type: .general)
    }
}
