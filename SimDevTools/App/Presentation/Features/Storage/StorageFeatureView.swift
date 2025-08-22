//
//  StorageView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//
import SwiftUI

struct StorageView: View {
    @StateObject private var store: Store<StorageFeatureReducer>

    init(
        storage: StorageFeatureStorage = UserDefaultsStorageFeatureStorage(
            db: UserDefaultsDatabase()
        ),
        accessProvider: CoreSimulatorAccessProviding = CoreSimulatorAccessProvider(),
        filesystem: CoreSimulatorFilesystem = DefaultCoreSimulatorFilesystem()
    ) {
        let reducer = StorageFeatureReducer.Env(
            storage: storage,
            accessProvider: accessProvider,
            filesystem: filesystem
        )
        _store = StateObject(
            wrappedValue: Store(
                initial: .init(),
                reducer: StorageFeatureReducer(env: reducer)
            )
        )
    }

    var body: some View {
        VStack {
            switch store.state.viewState {

            case .normal:
                ContentHeaderView(
                    titleText: "Storage",
                    message: headerMessage(),
                    button: .init(title: "Fetch") {
                        store.send(.readSelectedAppUserDefault)
                    }
                )

                contentList()

            case .loading:
                LoadingView()

            case .notConfigured:
                ContentHeaderView(
                    titleText: "Storage",
                    message: headerMessage(),
                    button: .init(title: "Open Configuration") {
                        store.send(.readSelectedAppUserDefault)
                    }
                )
                hint("No app bundle selected. Open Configuration and pick a target first.")

            case .accessNeeded:
                ContentHeaderView(
                    titleText: "Storage",
                    message: headerMessage(),
                    button: .init(title: "Grant Access") {
                        store.send(.readSelectedAppUserDefault)
                    }
                )
                hint("Access to ~/Library/Developer/CoreSimulator is required to read UserDefaults.")

            case .error:
                ContentHeaderView(
                    titleText: "Storage",
                    message: headerMessage(),
                    button: .init(title: "Retry") {
                        store.send(.readSelectedAppUserDefault)
                    }
                )
                hint("An error occurred. You can try again.")
            }

            Spacer()
        }
        .resizeToContentFrame()
        .onAppear { store.send(.onAppear) }
    }


    @ViewBuilder
    private func contentList() -> some View {
        VStack(alignment: .leading) {
            Text("This feature lets you **read** app UserDefaults from the simulator.")
                .padding(16)

            TextField("Search by key or value", text: Binding(
                get: { store.state.searchText },
                set: { store.send(.searchTextChanged($0)) }
            ))
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .padding(.bottom, 8)

            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(store.state.filteredEntries, id: \.id) { entry in
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.key)
                                    .font(.headline)
                                Text(entry.valueString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                Text(entry.kind.rawValue.uppercased())
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                if let n = entry.childCount {
                                    Text("\(n)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        .padding()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func hint(_ text: String) -> some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func headerMessage() -> HeaderMessageViewData? {
        switch store.state.viewState {
        case .loading:
            return HeaderMessageViewData(
                .init(text: "Loading (Storage)…", kind: .info)
            )
        default:
            break
        }
        if let msg = store.state.message {
            return HeaderMessageViewData(msg)
        }
        return nil
    }
}
