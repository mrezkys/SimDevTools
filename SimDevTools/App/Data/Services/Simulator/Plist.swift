//
//  Plist.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

enum Plist {
    static func topLevelDictionaryKeys(fromUTF8 text: String) throws -> [String] {
        guard let data = text.data(using: .utf8) else { throw SimulatorError.utf8Decoding }
        var fmt = PropertyListSerialization.PropertyListFormat.xml
        let obj = try PropertyListSerialization.propertyList(from: data, options: [], format: &fmt)
        guard let dict = obj as? [String: Any] else {
            throw SimulatorError.plistParsing("Top-level object is not a dictionary")
        }
        return Array(dict.keys)
    }
}
