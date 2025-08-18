//
//  DeveloperView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct DeveloperView: View {
    @ObservedObject var viewModel = DeveloperViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ContentHeaderView(
                    titleText: "Developer Support",
                    message: viewModel.message,
                    buttonEnabled: viewModel.viewState != .loading && viewModel.isFormValid,
                    buttonText: "Check",
                    buttonAction: {
                        viewModel.performCheck()
                    }
                )
                
                Picker("Type", selection: $viewModel.toolType) {
                    ForEach(DeveloperToolType.allCases, id: \.self) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                Text("What we do : \(viewModel.toolType.description)")
                    .padding(.horizontal)
                    .opacity(0.5)
                
                switch viewModel.toolType {
                case .missingResources:
                    MissingResourcesView(viewModel: viewModel)
                case .unconnectedOutletsXIB:
                    UnconnectedOutletsXIBView(viewModel: viewModel)
                case .unconnectedOutletsSwift:
                    Text("Swift Method Not Implemented")
                        .padding()
                case .unusedFiles:
                    Text("Method Not Implemented")
                        .padding()
                }
                switch viewModel.viewState {
                case .normal:
                    Spacer()
                case .loading:
                    HStack {
                        Text("Loading...")
                        Spacer().frame(width: 16)
                        ProgressView()
                            .controlSize(.mini)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.blue.opacity(0.2))
                    .cornerRadius(8)
                    .padding()
                case .completed:
                    VStack(alignment: .leading){
                        Text("Checking Complete")
                            .font(.title3)
                        Divider().padding(.vertical, 8)
                        if viewModel.warnings.isEmpty {
                            Text("No Issue Found.")
                        } else {
                            Text("\(viewModel.warnings.count) Issue Found.")
                                .padding(.bottom, 4)
                            Button("Open Detail") {
                                openPopupWindow()
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(viewModel.warnings.isEmpty ? .green.opacity(0.2) : .yellow.opacity(0.2))
                    .cornerRadius(8)
                    .padding()
                }
                Spacer()
                
            }
            
        }
        .resizeToContentFrame()
    }

    private func openPopupWindow(){
        let popupWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        
        popupWindow.center()
        popupWindow.isReleasedWhenClosed = false
        popupWindow.contentView = NSHostingView(rootView: DeveloperPopupView(viewModel: viewModel))
        popupWindow.makeKeyAndOrderFront(nil)
        popupWindow.title = "Developer View Detail"
    }
}

#Preview {
    DeveloperView()
}
