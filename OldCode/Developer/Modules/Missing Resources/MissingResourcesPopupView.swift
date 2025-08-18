//
//  MissingResourcesPopupView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 03/10/24.
//

import SwiftUI

struct MissingResourcesPopupView: View {
    @ObservedObject var viewModel: DeveloperViewModel

    var body: some View {
        HStack {
            Spacer()
        }
        Text("Found \(viewModel.warnings.count) warnings with \(viewModel.toolType.rawValue) Tool Type.")
            .font(.title3)
        VStack(alignment: .leading) {
            ForEach(viewModel.warnings, id: \.self) { warning in
                Text(warning.description)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemFill))
                .cornerRadius(8)
            }
        }
    }
}

//#Preview {
//    MissingResourcesPopupView()
//}
