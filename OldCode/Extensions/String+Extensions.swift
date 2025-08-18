//
//  String+Extensions.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

//import Foundation
//
//extension String {
//    func matchingStrings(pattern: String) -> [String] {
//        var matches = [String]()
//        do {
//            let regex = try NSRegularExpression(pattern: pattern, options: [])
//            let results = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
//            for match in results {
//                if let range = Range(match.range(at: 1), in: self) {
//                    matches.append(String(self[range]))
//                }
//            }
//        } catch {
//            print("Regex error: \(error)")
//        }
//        return matches
//    }
//}
