//
//  MissingResourcesView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct MissingResourcesView: View {
    @ObservedObject var viewModel: DeveloperViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Setup XCode Project")
                .font(.title3)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Select Project Path")
                    Spacer()
                    Button("Open") {
                        viewModel.showingFileImporter = true
                    }
                    .fileImporter(isPresented: $viewModel.showingFileImporter, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
                        switch result {
                        case .success(let urls):
                            if let url = urls.first {
                                viewModel.selectedProjectPath = url.path
                            }
                        case .failure(let error):
                            print("Error selecting file: \(error.localizedDescription)")
                        }
                    }
                }
                Text(viewModel.selectedProjectPath.isEmpty ? "No path selected" : viewModel.selectedProjectPath)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemFill))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Select PbxProj Path")
                    Spacer()
                    Button("Open") {
                        viewModel.showingPbxProjImporter = true
                    }
                    .fileImporter(
                        isPresented: $viewModel.showingPbxProjImporter,
                        allowedContentTypes: [.package],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let urls):
                            if let url = urls.first {
                                viewModel.selectedPBXProjPath = url.path
                            }
                        case .failure(let error):
                            print("Error selecting file: \(error.localizedDescription)")
                        }
                    }
                }
                Text(viewModel.selectedPBXProjPath.isEmpty ? "No path selected" : viewModel.selectedPBXProjPath)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemFill))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

//#Preview {
//    MissingResourcesView(viewModel: DeveloperViewModel())
//}
