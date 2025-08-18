//
//  SimDevToolsApp.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 18/08/25.
//

import SwiftUI

@main
struct iOSSimulatorToolsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 500)
    }
}

#Preview {
    ContentView()
}
