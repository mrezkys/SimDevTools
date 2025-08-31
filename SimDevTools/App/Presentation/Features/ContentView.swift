//
//  ContentView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedMenu: SidebarMenuType = .setting
    
    @StateObject private var settingStore = Store(
        initial: SettingState(),
        reducer: SettingReducer(env: .init(
            storage: UserDefaultsSettingStorage(db: UserDefaultsDatabase()),
            simulator: SimulatorService()
        ))
    )
    
    @StateObject private var storageStore = Store(
        initial: StorageFeatureState(),
        reducer: StorageFeatureReducer(env: .init(
            storage: UserDefaultsStorageFeatureStorage(db: UserDefaultsDatabase()),
            filesystem: DefaultCoreSimulatorFilesystem()
        ))
    )
    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedMenu: $selectedMenu)
            switch selectedMenu {
            case .setting:
                SettingView(store: settingStore)
            case .notification:
                NotificationView()
            case .storage:
                StorageView(store: storageStore)
            case .location:
                LocationView()
            }
        }
        .resizeToAppFrame()
    }
}

//#Preview {
//    ContentView()
//}
