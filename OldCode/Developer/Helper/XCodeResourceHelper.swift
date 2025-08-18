//
//  XCodeResourcesChecker.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import Foundation

class XCodeResourceHelper {
    private let fileManagerHelper: FileManagerHelper = FileManagerHelper()

    func checkProjectResources(projectPath: String, pbxprojPath: String, completion: @escaping (Result<[XCodeWarningModel], FileManagerError>) -> Void) {
        fileManagerHelper.files(at: projectPath, withExtension: "storyboard") { result in
            switch result {
            case .success(let storyboardFiles):
                self.fileManagerHelper.files(at: projectPath, withExtension: "xib") { result in
                    switch result {
                    case .success(let xibFiles):
                        let allFiles: [String] = storyboardFiles + xibFiles
                        self.fileManagerHelper.contentsOfFile(at: pbxprojPath) { result in
                            switch result {
                            case .success(let pbxprojContent):
                                let resources: [String] = pbxprojContent.components(separatedBy: "\n")
                                    .filter { $0.contains("fileRef") && ($0.contains(".storyboard") || $0.contains(".xib")) }
                                    .compactMap { line in
                                        let components = line.split(separator: " ").map(String.init)
                                        for component in components {
                                            if component.contains(".storyboard") || component.contains(".xib") {
                                                return component.replacingOccurrences(of: ";", with: "")
                                            }
                                        }
                                        return nil
                                    }

                                print(resources)

                                let missingResources: [String] = allFiles.filter { file in
                                    let fileName: String = URL(fileURLWithPath: file).lastPathComponent
                                    return !resources.contains(fileName)
                                }

                                var warnings: [XCodeWarningModel] = []
                                for resource in missingResources {
                                    warnings.append(XCodeWarningModel(type: .missingResource, xibName: nil, swiftName: nil, path: resource, details: nil))
                                }

                                completion(.success(warnings))

                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func checkUnconnectedOutletsFromXIB(projectPath: String, completion: @escaping (Result<[XCodeWarningModel], FileManagerError>) -> Void) {
        fileManagerHelper.files(at: projectPath, withExtension: "xib") { result in
            switch result {
            case .success(let xibFiles):
                var warnings: [XCodeWarningModel] = []
                let dispatchGroup = DispatchGroup()

                for xibFile in xibFiles {
                    dispatchGroup.enter()

                    self.fileManagerHelper.contentsOfFile(at: xibFile) { result in
                        switch result {
                        case .success(let xibContent):
                            guard let customClass: String = xibContent.matchingStrings(pattern: "<placeholder placeholderIdentifier=\"IBFilesOwner\"[^>]*customClass=\"([^\"]*)\"").first else {
                                dispatchGroup.leave()
                                return
                            }

                            self.findSwiftFilePath(projectPath: projectPath, className: customClass) { swiftFilePath in
                                if let swiftFilePath = swiftFilePath {
                                    self.fileManagerHelper.contentsOfFile(at: swiftFilePath) { result in
                                        switch result {
                                        case .success(let swiftContent):
                                            let swiftOutlets: [String] = swiftContent.matchingStrings(pattern: "@IBOutlet\\s+weak\\s+var\\s+([a-zA-Z0-9_]+):")
                                            let xibOutlets: [String] = xibContent.matchingStrings(pattern: "<outlet[^>]*property=\"([^\"]*)\"")

                                            let unconnectedOutlets: [String] = swiftOutlets.filter { !xibOutlets.contains($0) }
                                            for outlet in unconnectedOutlets {
                                                warnings.append(XCodeWarningModel(
                                                    type: .unconnectedOutlet,
                                                    xibName: URL(fileURLWithPath: xibFile).lastPathComponent,
                                                    swiftName: URL(fileURLWithPath: swiftFilePath).lastPathComponent,
                                                    path: xibFile,
                                                    details: "Outlet '\(outlet)' is not connected."
                                                ))
                                            }

                                        case .failure(let error):
                                            completion(.failure(error))
                                        }
                                        dispatchGroup.leave()
                                    }
                                } else {
                                    dispatchGroup.leave()
                                }
                            }

                        case .failure(let error):
                            completion(.failure(error))
                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    completion(.success(warnings))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Helper function to find Swift file path by class name
    private func findSwiftFilePath(projectPath: String, className: String, completion: @escaping (String?) -> Void) {
        fileManagerHelper.files(at: projectPath, withExtension: "swift") { result in
            switch result {
            case .success(let swiftFiles):
                let swiftFile = swiftFiles.first { $0.hasSuffix("\(className).swift") }
                completion(swiftFile)
            case .failure:
                completion(nil)
            }
        }
    }
}
