//
//  SettingView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//
import SwiftUI

struct SettingView: View {
    @StateObject private var store: Store<SettingReducer>

    init(
        storage: SettingStorage = UserDefaultsSettingStorage(
            db: UserDefaultsDatabase()
        ),
        simulator: SimulatorServiceProtocol = SimulatorService()
    ) {
        let reducer = SettingReducer(
            env: .init(
                storage: storage,
                simulator: simulator
            )
        )
        _store = StateObject(
            wrappedValue: Store(
                initial: .init(),
                reducer: reducer
            )
        )
    }

    var body: some View {
        VStack {
            switch store.state.viewState {
            case .normal:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: headerMessage(),
                    button: .init(title: "Save", enabled: store.state.canSave) {
                        store.send(.saveAppBundleButtonTapped)
                    }
                )

                VStack(alignment: .leading) {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)

            case .appsNotDetected, .simulatorNotDetected:
                ContentHeaderView(
                    titleText: "Configuration",
                    message: headerMessage(),
                    button: .init(title: "Detect App") {
                        store.send(.detectAppsTapped)
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
