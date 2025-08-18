//
//  DeveloperPopupView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 03/10/24.
//

import SwiftUI

struct DeveloperPopupView: View {
    @StateObject var viewModel: DeveloperViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                switch viewModel.toolType {
                case .missingResources:
                    MissingResourcesPopupView(viewModel: viewModel)
                case .unconnectedOutletsXIB:
                    UnconnectedOutletsXIBPopupView(viewModel: viewModel)
                case .unconnectedOutletsSwift:
                    EmptyView()
                case .unusedFiles:
                    EmptyView()
                }
                Spacer()
            }
            .padding()
        }
        .resizeToAppFrame()
    }
}
