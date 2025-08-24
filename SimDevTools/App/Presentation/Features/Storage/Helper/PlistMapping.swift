//
//  PlistMapping.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 23/08/25.
//

import Foundation

enum PlistMapping {
    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func mapPlistDictToEntries(
        _ dict: [String: Any],
        dateFormatter: ISO8601DateFormatter = PlistMapping.iso8601
    ) -> [UDEntry] {

        func classify(_ value: Any) -> (string: String, kind: UDEntry.Kind, childCount: Int?) {
            switch value {
            case let s as String:
                return (s, .string, nil)
            case let num as NSNumber:
                // Handle NSNumber specially - it can represent Bool, Int, or Double
                if num === kCFBooleanTrue as NSNumber || num === kCFBooleanFalse as NSNumber {
                    return (num.boolValue ? "true" : "false", .bool, nil)
                } else if num.doubleValue.rounded(.towardZero) == num.doubleValue {
                    // It's a whole number, treat as Int
                    return (String(num.intValue), .int, nil)
                } else {
                    // It's a decimal, treat as Double
                    return (String(num.doubleValue), .double, nil)
                }

            case let dt as Date:
                return (dateFormatter.string(from: dt), .date, nil)
            case let data as Data:
                return ("Data(\(data.count) bytes)", .data, nil)
            case let arr as [Any]:
                return ("Array(\(arr.count))", .array, arr.count)
            case let dict as [String: Any]:
                return ("Dictionary(\(dict.count))", .dict, dict.count)
            case _ as NSNull:
                return ("null", .null, nil)
            default:
                return ("\(value)", .unknown, nil)
            }
        }

        return dict.keys
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            .map { key in
                let value = dict[key] as Any
                let (s, kind, count) = classify(value)
                return UDEntry(key: key, valueString: s, kind: kind, childCount: count)
            }
    }
}
