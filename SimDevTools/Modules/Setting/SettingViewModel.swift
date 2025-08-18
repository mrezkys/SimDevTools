//
//  SettingViewModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//
import SwiftUI

enum SettingViewState {
    case normal
    case simulatorNotDetected
    case appsNotDetected
    case loading
}

class SettingViewModel: ObservableObject {
    @Published var viewState: SettingViewState = .normal {
        didSet {
            if viewState == .normal {
                message = nil
            }
        }
    }
    @Published var selectedAppBundle: String = ""
    @Published var appBundles: [String] = []
    @Published var message: ContentHeaderMessageModel? = nil
    @Published var canSaveSetting: Bool = false

    private let userDefaultsDatabase: UserDefaultsDatabaseProtocol

    init(userDefaultsDatabase: UserDefaultsDatabaseProtocol = UserDefaultsDatabase()) {
        self.userDefaultsDatabase = userDefaultsDatabase
        loadSavedData()
        formListener()
    }

    func getInstalledApps() {
        appBundles.removeAll()
        viewState = .loading
        message = .getLoadingMessage(for: "Get Installed Apps")

        let result: Result<[String], SimulatorHelperError> = SimulatorHelper.getBootedSimulatorApps()

        switch result {
        case .success(let appBundles):
            if appBundles.isEmpty {
                viewState = .appsNotDetected
                message = ContentHeaderMessageModel(text: "No installed apps found or failed to fetch app bundles.", type: .error)
            } else {
                viewState = .normal
                self.appBundles = appBundles
                selectedAppBundle = appBundles.first ?? ""
            }
        case .failure(let error):
            viewState = .simulatorNotDetected
            message = ContentHeaderMessageModel(text: error.localizedDescription, type: .error)
        }
    }

    func validateAppBundle() -> Bool {
        if selectedAppBundle.isEmpty {
            message = ContentHeaderMessageModel(text: "Please select an App Bundle before saving", type: .error)
            return false
        } else {
            return true
        }
    }

    func save() {
        if validateAppBundle() {
            message = ContentHeaderMessageModel(text: "Saved successfully", type: .success)
            userDefaultsDatabase.save(value: selectedAppBundle, forKey: .selectedAppBundle)
            loadSavedData()
            formListener()
        }
    }

    func loadSavedData() {
        selectedAppBundle = userDefaultsDatabase.getValue(forKey: .selectedAppBundle) ?? ""
    }

    func formListener() {
        if 
            selectedAppBundle != userDefaultsDatabase.getValue(forKey: .selectedAppBundle) ?? "" {
            canSaveSetting = true
        } else {
            canSaveSetting = false
        }
    }
}
