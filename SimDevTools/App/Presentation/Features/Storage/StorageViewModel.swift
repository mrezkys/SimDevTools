////
////  StorageViewModel.swift
////  InternalDeveloperTool
////
////  Created by Muhammad Rezky on 01/10/24.
////
//
//import SwiftUI
//
//enum StorageViewState {
//    case normal
//    case loading
//}
//
//class StorageViewModel: ObservableObject {
//    private let userDefaultsDatabase: UserDefaultsDatabaseProtocol
//
//    @Published var viewState: StorageViewState = .normal
//    @Published var userDefaults: [String: Any] = [:]
//    var filteredUserDefaults: [String: Any] {
//        if searchText.isEmpty {
//            return userDefaults
//        } else {
//            return userDefaults.filter { $0.key.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//    @Published var message: ContentHeaderMessageModel? = nil
//    @Published var searchText: String = ""
//
//    var bundleIdentifier: String?
//    var simulatorPath: String?
//
//    init(userDefaultsDatabase: UserDefaultsDatabaseProtocol = UserDefaultsDatabase()) {
//        self.userDefaultsDatabase = userDefaultsDatabase
//        getSelectedBundleIdentifier()
//    }
//    
////    func getSelectedBundleIdentifier() {
////        bundleIdentifier = userDefaultsDatabase.getValue(forKey: .selectedAppBundle)
////        print("Bundle Identifier:", bundleIdentifier ?? "None")
////    }
////    
////    func loadUserDefaults() {
////        viewState = .loading
////        message = .getLoadingMessage(for: "Load User Defaults")
////        print("Start Load User Defaults")
////        guard let bundleIdentifier = bundleIdentifier else {
////            message = ContentHeaderMessageModel(text: "No bundle identifier found.", type: .error)
////            viewState = .normal
////            return
////        }
////
////        let pathResult = SimulatorHelper.fetchSimulatorPath(for: bundleIdentifier)
////
////        switch pathResult {
////        case .success(let path):
////            simulatorPath = path
////            print("Simulator Path:", path)
////            userDefaults = readUserDefaults(at: path)
////            viewState = .normal
////            message = ContentHeaderMessageModel(text: "User defaults loaded successfully.", type: .success)
////        case .failure(let failure):
////            message = ContentHeaderMessageModel(text: failure.localizedDescription, type: .error)
////            print("Failed to fetch simulator path:", failure.localizedDescription)
////            viewState = .normal
////        }
////        print("End Load User Defaults")
////    }
////    
//    private let coreSimBookmarkKey = "CoreSimRootBookmark"
//    
//    func resolveCoreSimRootBookmark() -> URL? {
//        guard let data = UserDefaults.standard.data(forKey: coreSimBookmarkKey) else { return nil }
//        var stale = false
//        do {
//            let url = try URL(resolvingBookmarkData: data,
//                              options: [.withSecurityScope],
//                              relativeTo: nil,
//                              bookmarkDataIsStale: &stale)
//            return stale ? nil : url
//        } catch {
//            print("Resolve bookmark failed:", error)
//            return nil
//        }
//    }
//    
//    func findAppContainer(coreSimRoot: URL, bundleId: String) -> URL? {
//        let fm = FileManager.default
//        let devicesURL = coreSimRoot.appendingPathComponent("Devices", isDirectory: true)
//
//        guard let deviceDirs = try? fm.contentsOfDirectory(at: devicesURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
//            return nil
//        }
//
//        for device in deviceDirs {
//            let appsRoot = device.appendingPathComponent("data/Containers/Data/Application", isDirectory: true)
//            guard let appDirs = try? fm.contentsOfDirectory(at: appsRoot, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
//                continue
//            }
//            for appDir in appDirs {
//                let plist = appDir.appendingPathComponent("Library/Preferences/\(bundleId).plist", isDirectory: false)
//                if fm.fileExists(atPath: plist.path) {
//                    return appDir // Found the container (UUID folder)
//                }
//            }
//        }
//        return nil
//    }
//
//    func requestCoreSimRootIfNeeded() -> URL? {
//        if let url = resolveCoreSimRootBookmark() { return url }
//
//        let panel = NSOpenPanel()
//        panel.canChooseFiles = false
//        panel.canChooseDirectories = true
//        panel.allowsMultipleSelection = false
//        panel.prompt = "Grant Access"
//        panel.message = "Select the CoreSimulator folder (~/Library/Developer/CoreSimulator)."
//        panel.showsHiddenFiles = true
//        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
//            .appendingPathComponent("Library/Developer/CoreSimulator", isDirectory: true)
//
//        guard panel.runModal() == .OK, let url = panel.url else { return nil }
//        do {
//            let bookmark = try url.bookmarkData(options: .withSecurityScope,
//                                                includingResourceValuesForKeys: nil,
//                                                relativeTo: nil)
//            UserDefaults.standard.set(bookmark, forKey: coreSimBookmarkKey)
//            return url
//        } catch {
//            print("Failed to save bookmark:", error)
//            return nil
//        }
//    }
//
//    
//    private func readUserDefaults(at path: String) -> [String: Any] {
//        guard let bundleIdentifier = bundleIdentifier, !bundleIdentifier.isEmpty else {
//            let msg = "Bundle identifier is missing."
//            print("[readUserDefaults] ERROR:", msg)
//            message = ContentHeaderMessageModel(text: msg, type: .error)
//            return [:]
//        }
//        guard let coreSimRoot = requestCoreSimRootIfNeeded() ?? resolveCoreSimRootBookmark() else {
//            print("CoreSimulator root access not granted.")
//            return [:]
//        }
//        guard coreSimRoot.startAccessingSecurityScopedResource() else {
//            print("Failed to start security-scoped access.")
//            return [:]
//        }
//        defer { coreSimRoot.stopAccessingSecurityScopedResource() }
//
//        guard let appContainer = findAppContainer(coreSimRoot: coreSimRoot, bundleId: bundleIdentifier) else {
//            print("App container not found for \(bundleIdentifier)")
//            return [:]
//        }
//
//        let plistURL = appContainer.appendingPathComponent("Library/Preferences/\(bundleIdentifier).plist")
//        do {
//            let data = try Data(contentsOf: plistURL)
//            var fmt = PropertyListSerialization.PropertyListFormat.xml
//            let obj = try PropertyListSerialization.propertyList(from: data, options: [], format: &fmt)
//            return (obj as? [String: Any]) ?? [:]
//        } catch {
//            print("Read plist error:", error.localizedDescription)
//            return [:]
//        }
//    }
//
//    func updateUserDefault(key: String, value: Any) {
//        guard let simulatorPath = simulatorPath else {
//            message = ContentHeaderMessageModel(text: "Simulator path is missing.", type: .error)
//            return
//        }
//        var userDefaults = readUserDefaults(at: simulatorPath)
//        userDefaults[key] = value
//        saveUserDefaults(at: simulatorPath, userDefaults: userDefaults)
//        loadUserDefaults()
//        message = ContentHeaderMessageModel(text: "User default '\(key)' updated successfully.", type: .success)
//    }
//
//    private func saveUserDefaults(at path: String, userDefaults: [String: Any]) {
//        let plistPath = "\(path)/Library/Preferences/\(bundleIdentifier!).plist"
//        if let plistData = try? PropertyListSerialization.data(fromPropertyList: userDefaults, format: .xml, options: 0) {
//            try? plistData.write(to: URL(fileURLWithPath: plistPath))
//        } else {
//            message = ContentHeaderMessageModel(text: "Failed to save user defaults.", type: .error)
//        }
//    }
//}
