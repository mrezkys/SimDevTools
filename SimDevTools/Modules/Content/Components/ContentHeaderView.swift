//
//  ContentHeaderView.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 29/09/24.
//

import SwiftUI

// Business/domain representation of a header message
struct HeaderMessage: Equatable {
    enum Kind {
        case error
        case success
        case info
    }

    let text: String
    let kind: Kind
}

struct HeaderMessageViewData: Equatable {
    enum Kind { case error, success, info }

    let text: LocalizedStringKey
    let kind: Kind

    var iconName: String {
        switch kind {
        case .error:   "exclamationmark.triangle.fill"
        case .success: "checkmark.circle.fill"
        case .info:    "info.circle.fill"
        }
    }
    var tint: Color {
        switch kind {
        case .error:   .red
        case .success: .green
        case .info:    .blue
        }
    }
    var background: Color { tint.opacity(0.12) }
    
    init(_ m: HeaderMessage) {
        self.text = LocalizedStringKey(m.text)
        self.kind = {
            switch m.kind {
            case .error: .error
            case .success: .success
            case .info: .info
            }
        }()
    }
}

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



#Preview("Error Message") {
    let errorMessage = HeaderMessage(
        text: "An unexpected error has occurred.",
        kind: .error
    )
    ContentHeaderView(
        titleText: "Error Occurred",
        message: .init(errorMessage),
        button: .init(title: "Retry") {
            
        }
    )
}

#Preview("Success Message") {
    let successMessage = HeaderMessage(
        text: "Your operation was successful.",
        kind: .success
    )
    ContentHeaderView(
        titleText: "Success",
        message: .init(successMessage),
        button: .init(title: "Continue") {
            
        }
    )
}

#Preview("General Message") {
    let infoMessage = HeaderMessage(
        text: "Please review the details above.",
        kind: .info
    )
    ContentHeaderView(
        titleText: "Information",
        message: .init(infoMessage),
        button: .init(title: "Ok") {
            
        }
    )
}
