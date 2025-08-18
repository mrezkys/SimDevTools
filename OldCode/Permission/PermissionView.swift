//
//  PermissionView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import SwiftUI

struct PermissionView: View {
    @StateObject var viewModel: PermissionViewModel = PermissionViewModel()
    var body: some View {
        ScrollView {
            VStack {
                switch viewModel.viewState {
                case .notReset:
                    ContentHeaderView(
                        titleText: "Permission",
                        message: viewModel.message,
                        buttonEnabled: true,
                        buttonText: "Reset to Start",
                        buttonAction: {
                            viewModel.resetPermissions()
                        }
                    )
                    Spacer()
                case .normal:
                    ContentHeaderView(
                        titleText: "Permission",
                        message: viewModel.message,
                        buttonEnabled: true,
                        buttonText: "Reset",
                        buttonAction: {
                            viewModel.resetPermissions()
                        }
                    )
                    
                    VStack (alignment: .leading){
                        ForEach(viewModel.permissions) { permission in
                            VStack(alignment: .leading) {
                                Text(permission.displayName)
                                Picker("", selection: $viewModel.permissions[viewModel.permissions.firstIndex(of: permission)!].currentState) {
                                    ForEach(permission.availableStates, id: \.self) { state in
                                        Text(state.displayName)
                                    }
                                }
                                .onChange(
                                    of: viewModel.permissions[viewModel.permissions.firstIndex(of: permission)!].currentState
                                ) { newState in
                                    viewModel.setPermission(permission: permission, newState: newState)
                                }
                                .labelsHidden()
                                .pickerStyle(.menu)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding( 16)
                    Spacer()
                case .loading:
                    LoadingView()
                case .error:
                    ContentHeaderView(
                        titleText: "Permission",
                        message: viewModel.message,
                        buttonEnabled: true,
                        buttonText: "Re Init",
                        buttonAction: {
                            viewModel.initialSetup()
                            viewModel.resetPermissions()
                        }
                    )
                    EmptyView()
                }
            }
        }
        .resizeToContentFrame()
    }
}
