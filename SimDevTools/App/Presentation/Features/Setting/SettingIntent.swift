//
//  SettingIntent.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

enum SettingIntent: Equatable {
    case onAppear
    
    // simulator
    case detectAppsTapped
    case appsFetchedSuccess([String])
    case appsFetchedFailure(SimulatorError)

    // persistence
    case loadSavedAppBundle
    case savedAppBundleLoaded(String?)
    case saveAppBundleButtonTapped
    case saveAppBundleSuccess
    case saveAppBundleFailure(SimulatorError)

    // ui
    case appBundleSelected(String)
    case clearMessage
}


