//
//  UnconnectedOutletsXIBPopupView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 03/10/24.
//

import SwiftUI

struct UnconnectedOutletsXIBPopupView: View {
    @ObservedObject var viewModel: DeveloperViewModel
    var body: some View {
        HStack {
            Spacer()
        }
        Text("Found \(viewModel.warnings.count) warnings with \(viewModel.toolType.rawValue) Tool Type.")
            .font(.title3)
        VStack(alignment: .leading) {
            ForEach(viewModel.warningGroups, id: \.self) { group in
                DisclosureGroup(
                    content: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Found \(group.warnings.count) issue in this controller")
                                Spacer()
                                Button("Open") {}
                            }
                            Divider().padding(.vertical, 4)
                            ForEach(group.warnings, id: \.self) { warning in
                                Text("\(warning.description)")
                                    .padding(4)
                                    .background(Color(.quaternarySystemFill))
                                    .cornerRadius(4)
                                    .padding(.bottom, 2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    },
                    label: {
                        Text("\(group.swiftName)")
                            .font(.headline)
                    }
                )
                .padding()
                .background(Color(.secondarySystemFill))
                .cornerRadius(8)
            }
            
            
        }
    }
}

//#Preview {
//    UnconnectedOutletsXIBPopupView(viewModel: <#DeveloperViewModel#>)
//}
