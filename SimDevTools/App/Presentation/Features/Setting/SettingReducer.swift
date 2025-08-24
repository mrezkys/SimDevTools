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
                Effect { .initSettingData }
            ]
        case .initSettingData:
            state.viewState = .loading
            state.message = nil
            
            return [
                Effect { .getBootedSimulators },
            ]
        case .getBootedSimulators:
            return [
                Effect { [env] in
                    do {
                        let bootedSimulator = try await env.simulator.getBootedSimulators()
                        return .didSuccessGetBootedSimulators(bootedSimulator)
                    } catch let e as SimulatorError {
                        return .didFailedGetBootedSimulators(e)
                    } catch {
                        return .didFailedGetBootedSimulators(.commandFailed(error.localizedDescription))
                    }
                }
            ]
        case .didSuccessGetBootedSimulators(let bootedSimulators):
            if bootedSimulators.isEmpty {
                state.viewState = .simulatorNotDetected
                state.message = .init(
                    text: "You need to boot simulator",
                    kind: .error
                )
                return [.none]
            }
            state.viewState = .normal
            state.bootedSimulators = bootedSimulators
            return [
                Effect {
                    return .getSavedTargetSimulator
                }
            ]
        case .didFailedGetBootedSimulators(let err):
            state.viewState = .error
            state.message = .init(text: err.localizedDescription, kind: .error)
            return [.none]
        case .bootedSimulatorIDSelected(let selectedBootedSimulatorID):
            state.selectedBootedSimulatorID = selectedBootedSimulatorID
            state.message = nil
            return [
                Effect {
                    .saveTargetSimulatorTapped
                }
            ]
        case .getSavedTargetSimulator:
            return [
                Effect { [env] in
                    .savedTargetSimulatorLoaded(env.storage.loadTargetSimulatorID())
                }
            ]
            
        case .savedTargetSimulatorLoaded(let maybeSavedID):
            let saved = maybeSavedID ?? ""
            let isValid = !saved.isEmpty && state.bootedSimulators.contains { $0.udid == saved }
            if isValid {
                state.savedTargetSimulatorID = saved
                // prefer saved if user hasnt manually selected one yet
                if state.selectedBootedSimulatorID.isEmpty {
                    state.selectedBootedSimulatorID = saved
                }
            } else {
                state.savedTargetSimulatorID = ""
                // only clear selected if it points to a non booted device
                if !state.bootedSimulators.contains(where: { $0.udid == state.selectedBootedSimulatorID }) {
                    state.selectedBootedSimulatorID = ""
                }
            }

            if !state.selectedBootedSimulatorID.isEmpty, state.bootedSimulators .contains(where: { $0.udid == state.selectedBootedSimulatorID }) {
                return [
                    Effect { .getAppBundlesFromSimulator },
                    Effect { .loadSavedAppBundle }
                ]
            }

            return [ .none ]
            
            
        case .saveTargetSimulatorTapped:
            guard !state.selectedBootedSimulatorID.isEmpty else {
                state.message = .init(
                    text: "Please select an Target Simulator before Starting",
                    kind: .error
                )
                return [.none]
            }
            state.viewState = .loading
            let simulatorID = state.selectedBootedSimulatorID
            return [Effect { [env] in
                do {
                    try env.storage.saveTargetSimulatorID(simulatorID)
                    return .saveTargetSimulatorSuccess
                } catch {
                    return .saveTargetSimulatorSuccessFailed(.storageSaveError)
                }
            }]
        case .saveTargetSimulatorSuccess:
            state.viewState = .normal
            state.message = .init(text: "Saved successfully", kind: .success)
            return [
                Effect { [env] in
                    await env.sleepMS(2_000)
                    return .clearMessage
                },
                Effect { .getAppBundlesFromSimulator }
            ]
        case .saveTargetSimulatorSuccessFailed(let err):
            state.message = .init(text: "Error Saving: \(err.localizedDescription)", kind: .error)
            return [.none]
        case .getAppBundlesFromSimulator:
            let targetSimulatorID = state.selectedBootedSimulatorID
            return [
                Effect { .clearLoadedAppBundlesAndSelectedAppBundle },
                Effect { [env] in
                    do {
                        let bundles = try await env.simulator.getAppBundleIDs(forUDID: targetSimulatorID)
                        return .appsFetchedSuccess(bundles)
                    } catch let e as SimulatorError {
                        return .appsFetchedFailure(e)
                    } catch {
                        return .appsFetchedFailure(.commandFailed(error.localizedDescription))
                    }
                }
            ]
        case .clearLoadedAppBundlesAndSelectedAppBundle:
            state.appBundles = []
            state.selectedAppBundle = ""
            state.savedAppBundle = ""
            return [
                Effect { [env] in
                    do {
                        try env.storage.removeSavedAppBundle()
                        return .none
                    } catch {
                        return .none
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
                    state.selectedAppBundle = ""
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
            return [
                Effect {
                    .saveAppBundleButtonTapped
                }
            ]
        case .saveAppBundleButtonTapped:
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
            
        case .loadSavedAppBundle:
            return [
                Effect { [env] in
                        .savedAppBundleLoaded(env.storage.loadAppBundle())
                }
            ]
        case .savedAppBundleLoaded(let saved):
            if saved == nil {
                state.savedAppBundle = ""
                state.selectedAppBundle = ""
            } else {
                state.savedAppBundle = saved!
                state.selectedAppBundle = saved!
            }
            return [.none]
            

        }
    }
}
