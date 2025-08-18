//
//  XCodeWarningModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 03/10/24.
//

import Foundation

struct XCodeWarningModel: Hashable {
    var id: UUID = UUID()
    var type: XCodeWarningType
    var xibName: String?
    var swiftName: String?
    var path: String
    var details: String?

    var description: String {
        var desc = "\(type.rawValue) in \(path)"
        if let details = details {
            desc += " - \(details)"
        }
        return desc
    }
}
