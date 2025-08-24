//
//  SettingIntent.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

enum SettingIntent: Equatable {
    case onAppear
    case initSettingData
    
    case getBootedSimulators
    case didSuccessGetBootedSimulators([BootedSimulator])
    case didFailedGetBootedSimulators(SimulatorError)
    
    case getSavedTargetSimulator
    case savedTargetSimulatorLoaded(String?)
    case bootedSimulatorIDSelected(String)
    case saveTargetSimulatorTapped
    case saveTargetSimulatorSuccess
    case saveTargetSimulatorSuccessFailed(SettingFeatureError)

    case appsFetchedSuccess([String])
    case appsFetchedFailure(SimulatorError)

    case clearLoadedAppBundlesAndSelectedAppBundle
    case getAppBundlesFromSimulator
    case loadSavedAppBundle
    case appBundleSelected(String)
    case savedAppBundleLoaded(String?)
    case saveAppBundleButtonTapped
    case saveAppBundleSuccess
    case saveAppBundleFailure(SimulatorError)
    
    case clearMessage
}


