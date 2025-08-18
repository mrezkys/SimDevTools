//
//  ContentHeaderView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import SwiftUI

struct ContentHeaderView: View {
    let titleText: String
    let buttonText: String?
    let buttonEnabled: Bool?
    let buttonAction: (() -> Void)?
    let message: ContentHeaderMessageModel?
    
    var showMessage: Bool {
        return message != nil
    }
    
    init(
        titleText: String,
        message: ContentHeaderMessageModel? = nil,
        buttonEnabled: Bool? = nil,
        buttonText: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.titleText = titleText
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        self.message = message
        self.buttonEnabled = buttonEnabled
    }
    
    var body: some View {
        VStack(spacing: 0){
            HStack {
                Text(titleText)
                    .font(.headline)
                Spacer()
                if let buttonText = buttonText, let buttonAction = buttonAction {
                    Button(action: buttonAction) {
                        Text(buttonText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .frame(minWidth: 80)
                    }
                    .disabled(!(buttonEnabled ?? true))
                }
            }
            .padding(16)
            .border(
                Color.gray.opacity(0.2),
                width: 1
            )
            if let message = message {
                HStack(alignment: .center) {
                    Image(systemName: message.type.iconName)
                        .foregroundColor(message.type.backgroundColor)
                    Text(message.text)
                    Spacer()
                    
                }
                .padding(16)
                .background(message.type.backgroundColor.opacity(0.3))
                .transition(.slide)
            }
        }
    }
}



#Preview("Error Message") {
    ContentHeaderView(
        titleText: "Error Occurred",
        message: ContentHeaderMessageModel(text: "An unexpected error has occurred.", type: .error),
        buttonEnabled: true, 
        buttonText: "Retry",
        buttonAction: {
            // Retry action
        }
    )
}

#Preview("Success Message") {
    ContentHeaderView(
        titleText: "Success!",
        message: ContentHeaderMessageModel(text: "Your operation was successful.", type: .success),
        buttonEnabled: true, 
        buttonText: "Continue",
        buttonAction: {
            // Continue action
        }
    )
}

#Preview("General Message") {
    ContentHeaderView(
        titleText: "Information",
        message: ContentHeaderMessageModel(text: "Please review the details above.", type: .general),
        buttonEnabled: true,
        buttonText: "OK",
        buttonAction: {
            // OK action
        }
    )
}
