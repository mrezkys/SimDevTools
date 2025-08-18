//
//  DeveloperToolType.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 03/10/24.
//

import Foundation

enum DeveloperToolType: String, CaseIterable {
    case missingResources = "Missing Resources"
    case unconnectedOutletsXIB = "Unconnected Outlets (XIB Method)"
    case unconnectedOutletsSwift = "Unconnected Outlets (Swift Method)"
    case unusedFiles = "Unused Files"
    
    var description: String {
        switch self {
        case .missingResources:
            return "Finds resources that are missing from your project based on build."
        case .unconnectedOutletsXIB:
            return "Identifies unconnected outlets in XIB files by finding XIB & Storyboard files and check the Swift file that related to it and compare the outlet that the Swift File have but the XIB doesnt."
        case .unconnectedOutletsSwift:
            return "Detects unconnected outlets in Swift code by finding Swift files and check the XIB & Storyboard file that related to it and compare the outlet that the XIB/Storyboard have but the Swift doesnt"
        case .unusedFiles:
            return "Lists files that are no longer used in the project."
        }
    }
}
