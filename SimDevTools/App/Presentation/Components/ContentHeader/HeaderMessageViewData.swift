//
//  HeaderMessageViewData.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 21/08/25.
//

import SwiftUI

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
