//
//  UnconnectedOutletsXIBWarningGroup.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 03/10/24.
//

import Foundation

struct UnconnectedOutletsXIBWarningGroupModel: Hashable {
    var id: UUID = UUID()
    var swiftName: String
    var warnings: [XCodeWarningModel]
}
