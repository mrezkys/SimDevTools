//
//  NotificationViewModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import SwiftUI

enum NotificationViewState {
    case normal
    case loading
}

class NotificationViewModel: ObservableObject {
    @Published var jsonPayload: String = PushNotificationTemplate.basic.payload
    @Published var selectedTemplate: PushNotificationTemplate = .basic
    @Published var templates: [PushNotificationTemplate] = PushNotificationTemplate.allCases
    @Published var viewState: NotificationViewState = .normal
    @Published var message: ContentHeaderMessageModel? = nil
    
    private let userDefaultsDatabase: UserDefaultsDatabaseProtocol
    var bundleIdentifier: String?
    
    init(userDefaultsDatabase: UserDefaultsDatabaseProtocol = UserDefaultsDatabase()) {
        self.userDefaultsDatabase = userDefaultsDatabase
        getSelectedBundleIdentifier()
    }
    
    func getSelectedBundleIdentifier() {
        bundleIdentifier = userDefaultsDatabase.getValue(forKey: .selectedAppBundle)
        print("Bundle Identifier:", bundleIdentifier ?? "None")
    }
    
    func sendPushNotification() {
        let normalizedJsonPayload = jsonPayload.replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
    
        guard let bundleID = bundleIdentifier, !jsonPayload.isEmpty else {
            message = ContentHeaderMessageModel(text: "Bundle Identifier or JSON payload is missing.", type: .error)
            return
        }
        
        let command = "xcrun simctl push booted \(bundleID) -"
        let process = Process()
        let pipe = Pipe()
        let inputPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["bash", "-c", command]
        process.standardInput = inputPipe
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            print(jsonPayload)
            inputPipe.fileHandleForWriting.write(normalizedJsonPayload.data(using: .utf8)!)
            inputPipe.fileHandleForWriting.closeFile()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            DispatchQueue.main.async {
                self.message = ContentHeaderMessageModel(text: "Push notification sent successfully.", type: .success)
            }
        } catch {
            DispatchQueue.main.async {
                self.message = ContentHeaderMessageModel(text: "Failed to send push notification: \(error.localizedDescription)", type: .error)
            }
        }
    }
    
    func selectTemplate() {
        jsonPayload = selectedTemplate.payload
    }
}
