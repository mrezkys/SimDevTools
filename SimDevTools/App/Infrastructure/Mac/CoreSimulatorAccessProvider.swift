//
//  CoreSimulatorAccessProvider.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//

import AppKit
import Foundation

public final class CoreSimulatorAccessProvider: CoreSimulatorAccessProviding {
    private let bookmarkKey = "CoreSim.RootBookmark1"
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func coreSimRootURL() throws -> URL {
        guard let data = defaults.data(forKey: bookmarkKey) else {
            throw CoreSimulatorAccessError.noBookmark
        }
        var stale = false
        let url = try URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        )
        guard !stale else { throw CoreSimulatorAccessError.staleBookmark }
        return url
    }

    public func requestCoreSimRootIfNeeded() throws -> URL {
        // If we already have a valid bookmark, use it.
        if let url = try? coreSimRootURL() {
            return url
        }

        // Ask user to grant access to: ~/Library/Developer/CoreSimulator
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Grant Access"
        panel.message = "Select the CoreSimulator folder (~/Library/Developer/CoreSimulator)."
        panel.showsHiddenFiles = true
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Developer/CoreSimulator", isDirectory: true)

        guard panel.runModal() == .OK, let url = panel.url else {
            throw CoreSimulatorAccessError.userCancelled
        }

        do {
            let bookmark = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            defaults.set(bookmark, forKey: bookmarkKey)
            return url
        } catch {
            throw CoreSimulatorAccessError.bookmarkCreateFailed(error.localizedDescription)
        }
    }

    public func withCoreSimRoot<T>(_ body: (URL) throws -> T) throws -> T {
        let root = try requestCoreSimRootIfNeeded()
        guard root.startAccessingSecurityScopedResource() else {
            throw CoreSimulatorAccessError.startScopedAccessFailed
        }
        defer { root.stopAccessingSecurityScopedResource() }
        return try body(root)
    }
}
