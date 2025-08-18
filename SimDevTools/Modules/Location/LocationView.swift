//
//  LocationView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @StateObject private var viewModel: LocationViewModel = LocationViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ContentHeaderView(
                    titleText: "Mock Location",
                    message: viewModel.message,
                    buttonEnabled: true,
                    buttonText: "Set Location",
                    buttonAction: {
                        viewModel.setSimulatorLocation()
                    }
                )
                VStack(alignment: .leading, spacing: 0) {
                    MapViewRepresentable(region: $viewModel.region, selectedLocation: $viewModel.selectedLocation)
                        .frame(height: 200)
                        .cornerRadius(8)
                    Divider()
                        .padding(.vertical, 16)
                    TextField("Search Location", text: $viewModel.searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                        .onChange(of: viewModel.searchQuery) { _, _ in
                            viewModel.performSearch()
                        }
                    VStack(alignment: .leading) {
                        if !viewModel.searchResults.isEmpty {
                            Text("Search result...")
                                .font(.caption)
                                .padding(.top, 8)
                        }
                        VStack (alignment: .leading){
                            ForEach(viewModel.searchResults, id: \.id) { result in
                                Text(result.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color(.systemFill))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        viewModel.selectSearchResult(result)
                                    }
                            }
                        }
                    }
                Divider()
                        .padding(.vertical, 16)
                    VStack(alignment: .leading) {
                        Text("Latitude")
                        TextField("Latitude", text: $viewModel.latitude)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.large)
                    }
                    Spacer().frame(height: 16)
                    VStack(alignment: .leading) {
                        Text("Latitude")
                        TextField("Longitude", text: $viewModel.longitude)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.large)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .resizeToContentFrame()
    }
}

#Preview {
    LocationView()
}
