//
//  StorageViewModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import SwiftUI

enum StorageViewState {
    case normal
    case loading
}

class StorageViewModel: ObservableObject {
    private let userDefaultsDatabase: UserDefaultsDatabaseProtocol

    @Published var viewState: StorageViewState = .normal
    @Published var userDefaults: [String: Any] = [:]
    var filteredUserDefaults: [String: Any] {
        if searchText.isEmpty {
            return userDefaults
        } else {
            return userDefaults.filter { $0.key.localizedCaseInsensitiveContains(searchText) }
        }
    }
    @Published var message: ContentHeaderMessageModel? = nil
    @Published var searchText: String = ""

    var bundleIdentifier: String?
    var simulatorPath: String?

    init(userDefaultsDatabase: UserDefaultsDatabaseProtocol = UserDefaultsDatabase()) {
        self.userDefaultsDatabase = userDefaultsDatabase
        getSelectedBundleIdentifier()
    }
    
    func getSelectedBundleIdentifier() {
        bundleIdentifier = userDefaultsDatabase.getValue(forKey: .selectedAppBundle)
        print("Bundle Identifier:", bundleIdentifier ?? "None")
    }
    
    func loadUserDefaults() {
        viewState = .loading
        message = .getLoadingMessage(for: "Load User Defaults")
        print("Start Load User Defaults")
        guard let bundleIdentifier = bundleIdentifier else {
            message = ContentHeaderMessageModel(text: "No bundle identifier found.", type: .error)
            viewState = .normal
            return
        }

        let pathResult = SimulatorHelper.fetchSimulatorPath(for: bundleIdentifier)

        switch pathResult {
        case .success(let path):
            simulatorPath = path
            print("Simulator Path:", path)
            userDefaults = readUserDefaults(at: path)
            viewState = .normal
            message = ContentHeaderMessageModel(text: "User defaults loaded successfully.", type: .success)
        case .failure(let failure):
            message = ContentHeaderMessageModel(text: failure.localizedDescription, type: .error)
            print("Failed to fetch simulator path:", failure.localizedDescription)
            viewState = .normal
        }
        print("End Load User Defaults")
    }

    private func readUserDefaults(at path: String) -> [String: Any] {
        print("Reading UserDefaults at path:", path)
        guard let bundleIdentifier = bundleIdentifier else {
            message = ContentHeaderMessageModel(text: "Bundle identifier is missing.", type: .error)
            return [:]
        }

        let plistPath = "\(path)/Library/Preferences/\(bundleIdentifier).plist"
        print("Plist Path:", plistPath)

        if !FileManager.default.fileExists(atPath: plistPath) {
            message = ContentHeaderMessageModel(text: "Plist file does not exist at path: \(plistPath)", type: .error)
            return [:]
        }

        if let plistData = FileManager.default.contents(atPath: plistPath),
           let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
            print("Plist data:", plist)
            return plist
        } else {
            message = ContentHeaderMessageModel(text: "Failed to read or deserialize plist file.", type: .error)
            return [:]
        }
    }

    func updateUserDefault(key: String, value: Any) {
        guard let simulatorPath = simulatorPath else {
            message = ContentHeaderMessageModel(text: "Simulator path is missing.", type: .error)
            return
        }
        var userDefaults = readUserDefaults(at: simulatorPath)
        userDefaults[key] = value
        saveUserDefaults(at: simulatorPath, userDefaults: userDefaults)
        loadUserDefaults()
        message = ContentHeaderMessageModel(text: "User default '\(key)' updated successfully.", type: .success)
    }

    private func saveUserDefaults(at path: String, userDefaults: [String: Any]) {
        let plistPath = "\(path)/Library/Preferences/\(bundleIdentifier!).plist"
        if let plistData = try? PropertyListSerialization.data(fromPropertyList: userDefaults, format: .xml, options: 0) {
            try? plistData.write(to: URL(fileURLWithPath: plistPath))
        } else {
            message = ContentHeaderMessageModel(text: "Failed to save user defaults.", type: .error)
        }
    }
}
