//
//  UDEntry.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//



struct UDEntry: Equatable, Identifiable {
    enum Kind: String, Equatable {
        case string, int, double, bool, date, data, array, dict, null, unknown
    }

    /// Use key as stable identity (plist keys are unique at the top level).
    var id: String { key }

    let key: String
    let valueString: String      // What you show in the UI
    let kind: Kind               // Type information (for icon/tint, formatting, etc.)
    let childCount: Int?         // For arrays/dicts, number of elements
}

