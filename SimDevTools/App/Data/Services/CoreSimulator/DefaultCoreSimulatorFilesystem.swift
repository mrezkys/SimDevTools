//
//  DefaultCoreSimulatorFilesystem.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//

import Foundation

public struct DefaultCoreSimulatorFilesystem: CoreSimulatorFilesystem {
    public init() {}

    public func findAppContainer(coreSimRoot: URL, bundleId: String) throws -> URL {
        let fm = FileManager.default
        let devicesURL = coreSimRoot.appendingPathComponent("Devices", isDirectory: true)

        let deviceDirs: [URL]
        do {
            deviceDirs = try fm.contentsOfDirectory(
                at: devicesURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        } catch {
            throw CoreSimulatorFilesystemError.io("List devices failed: \(error.localizedDescription)")
        }

        for device in deviceDirs {
            let appsRoot = device.appendingPathComponent("data/Containers/Data/Application", isDirectory: true)

            guard let appDirs = try? fm.contentsOfDirectory(
                at: appsRoot,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }

            for appDir in appDirs {
                let prefsPlist = appDir.appendingPathComponent("Library/Preferences/\(bundleId).plist")
                if fm.fileExists(atPath: prefsPlist.path) {
                    return appDir // Found matching container (UUID folder)
                }
            }
        }

        throw CoreSimulatorFilesystemError.containerNotFound(bundleId: bundleId)
    }

    public func readUserDefaults(coreSimRoot: URL, bundleId: String) throws -> [String: Any] {
        let container = try findAppContainer(coreSimRoot: coreSimRoot, bundleId: bundleId)
        let plistURL = container.appendingPathComponent("Library/Preferences/\(bundleId).plist")

        do {
            let data = try Data(contentsOf: plistURL)
            var fmt = PropertyListSerialization.PropertyListFormat.xml
            let obj = try PropertyListSerialization.propertyList(from: data, options: [], format: &fmt)
            guard let dict = obj as? [String: Any] else {
                throw CoreSimulatorFilesystemError.plistNotDictionary
            }
            return dict
        } catch let e as CoreSimulatorFilesystemError {
            throw e
        } catch {
            throw CoreSimulatorFilesystemError.io("Read plist failed: \(error.localizedDescription)")
        }
    }
}
