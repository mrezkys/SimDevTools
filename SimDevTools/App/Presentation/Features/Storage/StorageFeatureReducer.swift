//
//  StorageFeatureReducer.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

struct StorageFeatureReducer: Reducer {
    struct Env {
        var storage: StorageFeatureStorage
        var filesystem: CoreSimulatorFilesystem
        var sleepMS: (_ ms: UInt64) async -> Void = { ms in try? await Task.sleep(nanoseconds: ms * 1_000_000) }
    }
    
    typealias State = StorageFeatureState
    typealias Intent = StorageFeatureIntent
    
    var env: Env
    
    mutating func reduce(state: inout StorageFeatureState, intent: StorageFeatureIntent) -> [Effect<StorageFeatureIntent>] {
        switch intent {
        case .onAppear:
            return [
                Effect { .loadAppBundle }
            ]
        case .loadAppBundle:
            return [
                Effect { [env] in
                        .appBundleLoaded(env.storage.loadAppBundle())
                }
            ]
        case .appBundleLoaded(let appBundle):
            if let appBundle = appBundle {
                state.bundleIdentifier = appBundle
            } else {
                state.message = .init(
                    text: "You need to select app bundle first at configuration menu",
                    kind: .error
                )
            }
            
            return [ .none ]
        case .readSelectedAppUserDefault:
            guard !state.bundleIdentifier.isEmpty else {
                state.viewState = .notConfigured
                state.message = .init(
                    text: "You need to select an app bundle first in Configuration.",
                    kind: .error
                )
                return [.none]
            }
            
            state.viewState = .loading
            state.message = nil
            
            let bundleId = state.bundleIdentifier
            return [Effect { [env] in
                do {
                    let root = await MainActor.run {
                        FileManager.default.homeDirectoryForCurrentUser
                            .appendingPathComponent("Library/Developer/CoreSimulator", isDirectory: true)
                    }
                    let dict = try env.filesystem.readUserDefaults(coreSimRoot: root, bundleId: bundleId)
                    let entries = PlistMapping.mapPlistDictToEntries(dict)
                    return .didSuccessReadSelectedAppUserDefault(entries)
                } catch let e as CoreSimulatorFilesystemError {
                    return .didErrorReadSelectedAppUserDefault(.fs(e))
                } catch {
                    return .didErrorReadSelectedAppUserDefault(.unknown(error.localizedDescription))
                }
            }]
            
        case .didSuccessReadSelectedAppUserDefault(let dict):
            state.rawEntries = dict
            state.viewState = .normal
            state.message = .init(text: "Loaded \(dict.count) keys.", kind: .success)
            return [
                Effect { [env] in
                    await env.sleepMS(1_000)
                    return .none
                }
            ]
            
        case .didErrorReadSelectedAppUserDefault(let err):
            switch err {
            case .notConfigured:
                state.viewState = .notConfigured
            default:
                state.viewState = .error
            }
            state.message = .init(text: err.message, kind: .error)
            return [.none]
        case .searchTextChanged(let q):
            state.searchText = q
            return [.none]
        case .clearMessage:
            state.message = nil
            return [.none]

        case .userToggledBoolean(let key, let newValue):
            guard !state.bundleIdentifier.isEmpty else {
                state.message = .init(
                    text: "You need to select an app bundle first in Configuration.",
                    kind: .error
                )
                return [.none]
            }
            return [Effect { .saveBooleanValue(key: key, newValue: newValue) }]

        case .saveBooleanValue(let key, let newValue):
            state.message = .init(text: "Updating \(key)...", kind: .info)

            let bundleId = state.bundleIdentifier
            return [Effect { [env] in
                do {
                    let root = await MainActor.run {
                        FileManager.default.homeDirectoryForCurrentUser
                            .appendingPathComponent("Library/Developer/CoreSimulator", isDirectory: true)
                    }
                    // convert Swift Bool to NSNumber for plist storage
                    let plistValue = newValue as NSNumber
                    try env.filesystem.writeUserDefaults(coreSimRoot: root, bundleId: bundleId, key: key, value: plistValue)

                    return .didSuccessSaveBooleanValue
                } catch let e as CoreSimulatorFilesystemError {
                    return .didErrorSaveBooleanValue(.fs(e))
                } catch {
                    return .didErrorSaveBooleanValue(.writeFailed(error.localizedDescription))
                }
            }]

        case .didSuccessSaveBooleanValue:
            state.message = .init(text: "Value updated successfully!", kind: .success)
            // refresh the data to show the updated value
            return [Effect { [state] in
                if !state.bundleIdentifier.isEmpty {
                    return .readSelectedAppUserDefault
                }
                return .none
            }]

        case .didErrorSaveBooleanValue(let err):
            state.message = .init(text: err.message, kind: .error)
            return [.none]
        }
    }
}
