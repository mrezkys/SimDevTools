//
//  ContentView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedMenu: SidebarMenuType = .setting
    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedMenu: $selectedMenu)
            switch selectedMenu {
            case .setting:
                SettingView()
            case .notification:
                NotificationView()
            case .storage:
                StorageView()
            case .permission:
                PermissionView()
            case .location:
                LocationView()
            case .developer:
                DeveloperView()
            case .performance:
                Text ("Performance not implemented yet")
                    .resizeToContentFrame()
            case .network:
                Text ("Network not implemented yet")
                    .resizeToContentFrame()
            }
        }
        .resizeToAppFrame()
    }
}

//#Preview {
//    ContentView()
//}
