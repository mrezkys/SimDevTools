//
//  HeaderMessage.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 21/08/25.
//

import Foundation

struct HeaderMessage: Equatable {
    enum Kind {
        case error
        case success
        case info
    }

    let text: String
    let kind: Kind
}
