//
//  NotificationView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import SwiftUI

struct NotificationView: View {
    @ObservedObject var viewModel = NotificationViewModel()
    
    var body: some View {
        VStack(alignment: .leading){
//            ContentHeaderView(
//                titleText: "Push Notification",
//                message: viewModel.message,
//                buttonEnabled: true,
//                buttonText: "Send",
//                buttonAction: {
//                    viewModel.sendPushNotification()
//                }
//            )
//            VStack(alignment: .leading) {
//                Text("Select Push Notification Template")
//                Picker("Select Template:", selection: $viewModel.selectedTemplate) {
//                    ForEach(viewModel.templates, id: \.id) { template in
//                        Text(template.rawValue).tag(template)
//                    }
//                }
//                .labelsHidden()
//                .pickerStyle(.menu)
//            }
//            .padding()
//            
//            TextEditor(text: $viewModel.jsonPayload)
//                .border(AppColor.separatorColor, width: 1)
//            
//            Spacer()
        }
        .resizeToContentFrame()
        .onChange(of: viewModel.selectedTemplate) { _, newTemplate in
            viewModel.jsonPayload = newTemplate.payload
        }
    }
}

#Preview {
    NotificationView()
}
