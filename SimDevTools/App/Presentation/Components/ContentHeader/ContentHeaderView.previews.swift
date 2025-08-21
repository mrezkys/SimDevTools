//
//  ContentHeaderView.previews.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 21/08/25.
//

import SwiftUI


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
