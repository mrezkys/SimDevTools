//
//  SidebarView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import SwiftUI

enum SidebarMenuType {
    case setting
    case notification
    case storage
    case location
}

struct SidebarView: View {
    @Binding var selectedMenu: SidebarMenuType
    var body: some View {
        ScrollView {
            VStack (alignment: .center){
                Spacer().frame(height: 16)
                Button {
                    selectedMenu = .setting
                } label: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(
                            width: 64,
                            height: 64
                        )
                }
                .opacity(selectedMenu == .setting ? 1 : 0.3)
                
                Button {
                    selectedMenu = .notification
                } label: {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(
                            width: 64,
                            height: 64
                        )
                }
                .opacity(selectedMenu == .notification ? 1 : 0.3)
                Button {
                    selectedMenu = .storage
                } label: {
                    Image(systemName: "macmini")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(
                            width: 64,
                            height: 64
                        )
                }
                .opacity(selectedMenu == .storage ? 1 : 0.3)
                
                Button {
                    selectedMenu = .location
                } label: {
                    Image(systemName: "safari")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(
                            width: 64,
                            height: 64
                        )
                }
                .opacity(selectedMenu == .location ? 1 : 0.3)
                Spacer()
            }
            .frame(
                width: 100,
                alignment: .center
            )
        }
        .border(
            color: AppColor.separatorColor,
            width: 1,
            sides: [.trailing]
        )
    }
}

#Preview {
    @State var selectedMenu: SidebarMenuType = .setting
    return SidebarView(selectedMenu: $selectedMenu)
}
