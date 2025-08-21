//
//  ContentHeaderView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import SwiftUI

struct ContentHeaderView: View {
    struct ButtonConfig {
        let title: LocalizedStringKey
        var enabled: Bool = true
        let onTap: () -> Void
    }

    let titleText: String
    let button: ButtonConfig?
    let message: HeaderMessageViewData?

    init(
        titleText: String,
        message: HeaderMessageViewData? = nil,
        button: ButtonConfig? = nil
    ) {
        self.titleText = titleText
        self.message = message
        self.button = button
    }
    
    var body: some View {
        VStack(spacing: 0){
            HStack {
                Text(titleText)
                    .font(.headline)
                Spacer()
                if let button = button {
                    Button(action: button.onTap) {
                        Text(button.title)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .frame(minWidth: 80)
                    }
                    .disabled(!button.enabled)
                }
            }
            .padding(16)
            .border(
                Color.gray.opacity(0.2),
                width: 1
            )
            if let message = message {
                HStack(alignment: .center) {
                    Image(systemName: message.iconName)
                        .foregroundColor(message.tint)
                    Text(message.text)
                    Spacer()
                    
                }
                .padding(16)
                .background(message.background)
                .transition(.slide)
            }
        }
    }
}


