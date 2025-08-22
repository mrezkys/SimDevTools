//
//  StorageState.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

enum StorageFeatureViewState: Equatable {
    case normal
    case loading
    case notConfigured         // no bundle id saved
    case accessNeeded          // no/stale bookmark or user cancelled
    case error                 // generic error
}

struct StorageFeatureState: Equatable {
    var viewState: StorageFeatureViewState = .normal
    var bundleIdentifier: String = ""
    var simulatorPath: String? = nil
    var message: HeaderMessage? = nil
    var searchText: String = ""
    var rawEntries: [UDEntry] = []
    
    var filteredEntries: [UDEntry] {
        guard !searchText.isEmpty else { return rawEntries }
        let q = searchText.lowercased()
        return rawEntries.filter { $0.key.lowercased().contains(q) || $0.valueString.lowercased().contains(q) }
    }
}

