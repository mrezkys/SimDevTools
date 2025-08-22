//
//  StorageState.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

import Foundation

/// A typed error that wraps infra/service errors into something feature-specific.
enum StorageFeatureError: Equatable, Error {
    case notConfigured
    case access(CoreSimulatorAccessError)
    case fs(CoreSimulatorFilesystemError)
    case unknown(String)

    var message: String {
        switch self {
        case .notConfigured:
            return "You need to select an app bundle first in Configuration."
        case .access(let e):
            switch e {
            case .noBookmark:                 return "CoreSimulator location not granted."
            case .staleBookmark:              return "Stored CoreSimulator permission is stale."
            case .userCancelled:              return "Access to CoreSimulator was cancelled."
            case .startScopedAccessFailed:    return "Failed to start security-scoped access."
            case .bookmarkCreateFailed(let s):return "Failed to create permission bookmark: \(s)"
            }
        case .fs(let e):
            switch e {
            case .containerNotFound(let b):   return "App container not found for \(b)."
            case .plistNotDictionary:         return "Preferences plist is not a dictionary."
            case .io(let s):                  return s
            }
        case .unknown(let s):
            return s
        }
    }
}

enum StorageFeatureViewState: Equatable {
    case normal
    case loading
    case notConfigured         // no bundle id saved
    case accessNeeded          // no/stale bookmark or user cancelled
    case error                 // generic error
}

struct StorageFeatureState: Equatable {
    var viewState: StorageFeatureViewState = .normal
    var bundleIdentifier: String = ""
    var simulatorPath: String? = nil
    var message: HeaderMessage? = nil
    var searchText: String = ""
    var rawEntries: [UDEntry] = []
    
    var filteredEntries: [UDEntry] {            // <- convenience for the View
        guard !searchText.isEmpty else { return rawEntries }
        let q = searchText.lowercased()
        return rawEntries.filter { $0.key.lowercased().contains(q) || $0.valueString.lowercased().contains(q) }
    }
}


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


/// Maps a raw plist dictionary `[String: Any]` into UI-friendly `[UDEntry]`.
/// - Parameters:
///   - dict: Raw dictionary from PropertyListSerialization.
///   - dateFormatter: Optional override if you want different date formatting.
/// - Returns: Entries sorted by key (case-insensitive).
func mapPlistDictToEntries(
    _ dict: [String: Any],
    dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
) -> [UDEntry] {

    func classify(_ value: Any) -> (string: String, kind: UDEntry.Kind, childCount: Int?) {
        switch value {
        case let s as String:
            return (s, .string, nil)

        case let i as Int:
            return (String(i), .int, nil)

        case let d as Double:
            // Avoid showing scientifically-notated doubles for whole numbers
            let s = d.rounded(.towardZero) == d ? String(Int(d)) : String(d)
            return (s, .double, nil)

        case let b as Bool:
            return (b ? "true" : "false", .bool, nil)

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
            // Fallback for CFNumber/NSNumber variants, etc.
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
