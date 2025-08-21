//
//  SettingView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import SwiftUI


struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .normal:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: viewModel.headerMessageViewData,
                    button: .init(title: "Save") {
                        viewModel.save()
                    }
                )
                VStack(alignment: .leading) {
                    Text("Select App target")
                    Picker("", selection: $viewModel.selectedAppBundle) {
                        ForEach(viewModel.appBundles, id: \.self) { appBundle in
                            Text(appBundle)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .padding(.bottom, 8)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            case .appsNotDetected, .simulatorNotDetected:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: viewModel.headerMessageViewData,
                    button: .init(title: "Detect App") {
                        viewModel.getInstalledApps()
                    }
                )
            case .loading:
                LoadingView()
            case .error:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: viewModel.headerMessageViewData
                )
            }
            Spacer()
        }
        .resizeToContentFrame()
        .onChange(of: viewModel.selectedAppBundle) { _, _ in
            viewModel.formListener()
        }
        .onAppear {
            DispatchQueue.main.async {
                viewModel.getInstalledApps()
                viewModel.loadSavedData()
            }
        }
    }
}

//#Preview {
//    SettingView()
//}
