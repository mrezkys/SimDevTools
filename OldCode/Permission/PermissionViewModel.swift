//
//  PermissionViewModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 04/10/24.
//

import Foundation

enum PermissionViewState {
    case notReset
    case normal
    case loading
    case error
}

class PermissionViewModel: ObservableObject {
    @Published var viewState: PermissionViewState = .notReset
    @Published var message: ContentHeaderMessageModel?
    @Published var permissions: [Permission] = []
    var bundleIdentifier: String?
    var userDefaultsDatabase: UserDefaultsDatabaseProtocol

    init(userDefaultsDatabase: UserDefaultsDatabaseProtocol = UserDefaultsDatabase()) {
        self.userDefaultsDatabase = userDefaultsDatabase
        initialSetup()
    }
    
    func initialSetup() {
        getSelectedBundleIdentifier()
    }

    private func getSelectedBundleIdentifier() {
        viewState = .loading
        message = .getLoadingMessage(for: "Get Bundle Identifier")
        bundleIdentifier = nil
        bundleIdentifier = userDefaultsDatabase.getValue(forKey: .selectedAppBundle)
        viewState = .notReset
        message = nil
    }

    private func loadPermissions() {
        let services = [
            Permission(serviceName: "calendar", displayName: "Calendar", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "camera", displayName: "Camera", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "contacts", displayName: "Contacts", availableStates: PermissionState.contactsStates),
            Permission(serviceName: "health", displayName: "Health", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "homekit", displayName: "HomeKit", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "microphone", displayName: "Microphone", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "motion", displayName: "Motion & Fitness", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "photos", displayName: "Photos", availableStates: PermissionState.photosStates),
            Permission(serviceName: "reminders", displayName: "Reminders", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "siri", displayName: "Siri", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "speech", displayName: "Speech Recognition", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "media-library", displayName: "Media Library", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "bluetooth", displayName: "Bluetooth", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "faceid", displayName: "Face ID", availableStates: PermissionState.grantRevokeResetStates),
            Permission(serviceName: "location", displayName: "Location", availableStates: PermissionState.locationStates),
            Permission(serviceName: "notifications", displayName: "Notifications", availableStates: PermissionState.grantRevokeResetStates)
        ]

        permissions = services.map { permission in
            var updatedPermission = permission
            updatedPermission.currentState = PermissionState.defaultState(for: permission.serviceName)
            return updatedPermission
        }
    }

    func resetPermissions() {
        viewState = .loading
        message = .getLoadingMessage(for: "Reset Permission")

        let process = Process()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "privacy", "booted", "reset", "all"]

        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            viewState = .error
            print(error)
            message = ContentHeaderMessageModel(text: "Failed to start process: \(error.localizedDescription)", type: .error)
            return
        }

        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            message = ContentHeaderMessageModel(text: "Error: \(errorOutput)", type: .error)
            viewState = .error
        } else {
            message = ContentHeaderMessageModel(text: "Permissions reset successfully.", type: .success)
            loadPermissions()
            viewState = .normal
        }
    }

    func setPermission(permission: Permission, newState: PermissionState) {
        guard let bundleIdentifier = bundleIdentifier else {
            message = ContentHeaderMessageModel(text: "Simulator UDID not found.", type: .error)
            viewState = .error
            return
        }

        let process = Process()
        let errorPipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")

        var action = ""
        var serviceArgument = permission.serviceName

        switch newState {
        case .granted, .readWrite, .always:
            action = "grant"
        case .denied, .readOnly, .never:
            action = "revoke"
        case .notDetermined:
            action = "reset"
        default:
            action = "reset"
        }

        // Handle special cases for services with multiple states
        if permission.serviceName == "photos" {
            if newState == .readWrite {
                action = "grant"
                serviceArgument = "photos"
            } else if newState == .readOnly {
                action = "grant"
                serviceArgument = "photos-add"
            } else if newState == .denied {
                action = "revoke"
                serviceArgument = "photos"
            } else if newState == .notDetermined {
                action = "reset"
                serviceArgument = "photos"
            }
        } else if permission.serviceName == "contacts" {
            if newState == .granted {
                action = "grant"
                serviceArgument = "contacts"
            } else if newState == .limited {
                action = "grant"
                serviceArgument = "contacts-limited"
            } else if newState == .denied {
                action = "revoke"
                serviceArgument = "contacts"
            } else if newState == .notDetermined {
                action = "reset"
                serviceArgument = "contacts"
            }
        } else if permission.serviceName == "location" {
            if newState == .always {
                action = "grant"
                serviceArgument = "location-always"
            } else if newState == .inUse {
                action = "grant"
                serviceArgument = "location"
            } else if newState == .never {
                action = "revoke"
                serviceArgument = "location"
            } else if newState == .notDetermined {
                action = "reset"
                serviceArgument = "location"
            }
        }

        process.arguments = ["simctl", "privacy", "booted", action, serviceArgument, bundleIdentifier]

        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            message = ContentHeaderMessageModel(text: "Failed to start process: \(error.localizedDescription)", type: .error)
            viewState = .error
            return
        }

        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            message = ContentHeaderMessageModel(text: "Error: \(errorOutput)", type: .error)
            viewState = .error
        } else {
            message = ContentHeaderMessageModel(
                text: "\(permission.displayName) permission for \(bundleIdentifier) set to \(newState.displayName).",
                type: .success
            )
            viewState = .normal
        }
    }
}
