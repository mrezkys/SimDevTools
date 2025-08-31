//
//  StorageView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//
import SwiftUI

struct StorageView: View {
    @ObservedObject var store: Store<StorageFeatureReducer>
    
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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("This feature lets you **read and write** app UserDefaults from the simulator. Toggle switches for boolean values save automatically.")
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                TextField("Search by key or value", text: Binding(
                    get: { store.state.searchText },
                    set: { store.send(.searchTextChanged($0)) }
                ))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(store.state.filteredEntries, id: \.id) { entry in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.key)
                                        .font(.headline)

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

                                Spacer()

                                if entry.kind == .bool {
                                    Toggle("", isOn: Binding(
                                        get: { entry.valueString == "true" },
                                        set: { newValue in
                                            store.send(.userToggledBoolean(key: entry.key, newValue: newValue))
                                        }
                                    ))
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                } else {
                                    Text(entry.valueString)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            Divider()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
