//
//  SettingView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//
import SwiftUI

struct SettingView: View {
    @ObservedObject var store: Store<SettingReducer>
    
    var body: some View {
        VStack {
            switch store.state.viewState {
            case .normal:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: headerMessage()
                )
                
                VStack(alignment: .leading) {
                    Text("Select Simulator Target")
                    Picker("", selection: Binding(
                        get: { store.state.selectedBootedSimulatorID },
                        set: { store.send(.bootedSimulatorIDSelected($0)) }
                    )) {
                        ForEach(store.state.bootedSimulators, id: \.self) { bootedSimulator in
                            Text("\(bootedSimulator.name) (\(bootedSimulator.udid))").tag(bootedSimulator.id)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .padding(.bottom, 8)
                    if !store.state.appBundles.isEmpty {
                        Text("Select App target")
                        Picker("", selection: Binding(
                            get: { store.state.selectedAppBundle },
                            set: { store.send(.appBundleSelected($0)) }
                        )) {
                            ForEach(store.state.appBundles, id: \.self) { bundle in
                                Text(bundle)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .padding(.bottom, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
            case .simulatorNotDetected:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: headerMessage(),
                    button: .init(title: "Refresh") {
                        store.send(.initSettingData)
                    }
                )
                
            case .appsNotDetected:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: headerMessage(),
                    button: .init(title: "Refresh") {
                        store.send(.initSettingData)
                    }
                )
                
            case .loading:
                LoadingView()
                
            case .error:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: headerMessage()
                )
            }
            
            Spacer()
        }
        .resizeToContentFrame()
        .onAppear { store.send(.onAppear) }
    }
    
    private func headerMessage() -> HeaderMessageViewData? {
        if case .loading = store.state.viewState {
            return HeaderMessageViewData(
                .init(
                    text: "Loading (Settings)…", kind: .info
                )
            )
        }
        if let msg = store.state.message {
            return HeaderMessageViewData(msg)
        }
        return nil
    }
}
