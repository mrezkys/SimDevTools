//
//  SettingState.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

enum SettingViewState: Equatable {
    case normal
    case simulatorNotDetected
    case appsNotDetected
    case loading
    case error
}

struct SettingState: Equatable {
    var hasBeenInitialized: Bool = false
    var viewState: SettingViewState = .normal
    var selectedAppBundle: String = ""
    var savedAppBundle: String = ""
    var appBundles: [String] = []

    var bootedSimulators: [BootedSimulator] = []
    var selectedBootedSimulatorID: String = ""
    var savedTargetSimulatorID: String = ""
    
    var message: HeaderMessage? = nil
    
    var canSave: Bool {
        return true
//        !selectedAppBundle.isEmpty && selectedAppBundle != savedAppBundle
    }
}
