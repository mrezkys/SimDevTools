//
//  StorageView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import SwiftUI

struct StorageView: View {
    @StateObject var viewModel: StorageViewModel = StorageViewModel()
    var body: some View {
        VStack {
//            switch viewModel.viewState {
//            case .normal:
//                ContentHeaderView(
//                    titleText: "Storage",
//                    message: viewModel.message,
//                    buttonEnabled: true,
//                    buttonText: "Fetch",
//                    buttonAction: {
//                        viewModel.loadUserDefaults()
//                    }
//                )
//                VStack(alignment: .leading) {
//                    Text("Currently this feature just can r/w for userdefaults storage.")
//                        .padding(16)
//                    TextField("Search by key", text: $viewModel.searchText)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.horizontal)
//                        .padding(.bottom, 8)
//                    List {
//                        ForEach(viewModel.filteredUserDefaults.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
//                            HStack {
//                                Text(key)
//                                    .font(.headline)
//                                    .padding(.trailing, 16)
//                                Spacer()
//                                if let boolValue: Bool = value as? Bool {
//                                    Toggle(isOn: Binding(
//                                        get: { boolValue },
//                                        set: { newValue in
//                                            viewModel.updateUserDefault(key: key, value: newValue)
//                                        }
//                                    )) {
//                                    }
//                                    .toggleStyle(SwitchToggleStyle())
//                                } else {
//                                    Text("\(value)")
//                                }
//                            }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            case .loading:
//                LoadingView()
//            }
//            Spacer()
        }
        .resizeToContentFrame()
        .onAppear{
            Task {
//                viewModel.loadUserDefaults()
            }
        }
    }
}

#Preview {
    StorageView()
}
