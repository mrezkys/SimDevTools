//
//  SettingReducer.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

struct SettingReducer: Reducer {
    struct Env {
        var storage: SettingStorage
        var simulator: SimulatorServiceProtocol
        var sleepMS: (_ ms: UInt64) async -> Void = { ms in
            try? await Task.sleep(nanoseconds: ms * 1_000_000)
        }
    }
    
    typealias State = SettingState
    typealias Intent = SettingIntent
    
    var env: Env
    
    
    mutating func reduce(state: inout SettingState, intent: SettingIntent) -> [Effect<SettingIntent>] {
        switch intent {
        case .onAppear:
            return [
                Effect { .loadSavedAppBundle },
                Effect { .detectAppsTapped }
            ]
        case .loadSavedAppBundle:
            return [
                Effect { [env] in
                        .savedAppBundleLoaded(env.storage.loadAppBundle())
                }
            ]
        case .savedAppBundleLoaded(let saved):
            state.savedAppBundle = saved ?? ""
            if state.selectedAppBundle.isEmpty {
                state.selectedAppBundle = state.savedAppBundle
            }
            return [.none]
            

        case .detectAppsTapped:
            state.viewState = .loading
            state.message = nil
            return [
                Effect { [env] in
                    do {
                        let bundles = try await env.simulator.getBootedAppBundleIDs()
                        return .appsFetchedSuccess(bundles)
                    } catch let e as SimulatorError {
                        return .appsFetchedFailure(e)
                    } catch {
                        return .appsFetchedFailure(.commandFailed(error.localizedDescription))
                    }
                }
            ]
        case .appsFetchedSuccess(let bundles):
            if bundles.isEmpty {
                state.viewState = .appsNotDetected
                state.message = .init(
                    text: "No installed apps found or failed to fetch app bundles.",
                    kind: .error
                )
            } else {
                state.viewState = .normal
                state.appBundles = bundles.sorted()

                if !state.savedAppBundle.isEmpty, bundles.contains(state.savedAppBundle) {
                    state.selectedAppBundle = state.savedAppBundle
                } else {
                    state.selectedAppBundle = bundles.first ?? ""
                }
                state.message = nil
            }
            return [.none]
        case .appsFetchedFailure(let err):
            if err == .noDevicesAreBooted {
                state.viewState = .simulatorNotDetected
            } else {
                state.viewState = .error
            }
            state.message = .init(text: err.localizedDescription, kind: .error)
            return [.none]
        case .appBundleSelected(let bundle):
            state.selectedAppBundle = bundle
            state.message = nil
            return [.none]
        case .saveAppBundleButtonTapped:
            guard !state.selectedAppBundle.isEmpty else {
                state.message = .init(
                    text: "Please select an App Bundle before saving",
                    kind: .error
                )
                return [.none]
            }
            state.viewState = .loading
            let bundle = state.selectedAppBundle
            return [Effect { [env] in
                do {
                    try env.storage.saveAppBundle(bundle)
                    return .saveAppBundleSuccess
                } catch let e as SimulatorError {
                    return .saveAppBundleFailure(e)
                } catch {
                    return .saveAppBundleFailure(.commandFailed(error.localizedDescription))
                }
            }]
        case .saveAppBundleSuccess:
            state.savedAppBundle = state.selectedAppBundle
            state.viewState = .normal
            state.message = .init(text: "Saved successfully", kind: .success)
            // auto-clear message after 2s (optional)
            return [Effect { [env] in
                await env.sleepMS(2_000)
                return .clearMessage
            }]
        case .saveAppBundleFailure(let err):
            state.viewState = .error
            state.message = .init(text: err.localizedDescription, kind: .error)
            return [.none]
        case .clearMessage:
            state.message = nil
            return [.none]
        }
    }
}
