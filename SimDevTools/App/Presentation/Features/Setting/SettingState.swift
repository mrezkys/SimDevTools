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
    var viewState: SettingViewState = .normal
    var selectedAppBundle: String = ""
    var savedAppBundle: String = ""
    var appBundles: [String] = []
    
    var message: HeaderMessage? = nil
    
    var canSave: Bool {
        !selectedAppBundle.isEmpty && selectedAppBundle != savedAppBundle
    }
}
