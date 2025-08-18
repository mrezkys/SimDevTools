//
//  FileManagerHelper.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import Foundation

enum FileManagerError: Error, CustomStringConvertible {
    case invalidProjectPath(String)
    case invalidPbxprojPath(String)
    case fileReadError(String, Error)
    case directoryReadError(String)

    var description: String {
        switch self {
        case .invalidProjectPath(let path):
            return "Invalid project path: \(path)"
        case .invalidPbxprojPath(let path):
            return "Invalid pbxproj path: \(path)"
        case .fileReadError(let path, let error):
            return "Failed to read file at path: \(path), Error: \(error.localizedDescription)"
        case .directoryReadError(let path):
            return "Failed to read directory at path: \(path)"
        }
    }
}

class FileManagerHelper {
    private let fileManager: FileManager = FileManager.default

    /// Get all files with the specified extension at the given path, recursively
    /// - Parameters:
    ///   - path: The directory path to search
    ///   - ext: The file extension to search for
    ///   - completion: Completion handler returning either the file paths or an error
    func files(at path: String, withExtension ext: String, completion: @escaping (Result<[String], FileManagerError>) -> Void) {
        let url = URL(fileURLWithPath: path)
        DispatchQueue.global(qos: .background).async {
            var foundFiles: [String] = []

            if let enumerator = self.fileManager.enumerator(at: url, includingPropertiesForKeys: nil) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == ext {
                        foundFiles.append(fileURL.path)
                    }
                }
                DispatchQueue.main.async {
                    completion(.success(foundFiles))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.directoryReadError(path)))
                }
            }
        }
    }

    /// Read the contents of a file at the given path
    /// - Parameters:
    ///   - path: The path of the file to read
    ///   - completion: Completion handler returning either the file content or an error
    func contentsOfFile(at path: String, completion: @escaping (Result<String, FileManagerError>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let content: String = try String(contentsOfFile: path, encoding: .utf8)
                DispatchQueue.main.async {
                    completion(.success(content))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.fileReadError(path, error)))
                }
            }
        }
    }
}
