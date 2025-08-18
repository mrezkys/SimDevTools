//
//  DeveloperViewModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 03/10/24.
//

import Foundation

enum DeveloperViewState {
    case normal
    case loading
    case completed
}

class DeveloperViewModel: ObservableObject {
    @Published var selectedProjectPath: String = ""
    @Published var selectedPBXProjPath: String = ""
    private var formattedPBXProjPath: String {
        return "\(selectedPBXProjPath)/project.pbxproj"
    }
    @Published var toolType: DeveloperToolType = .missingResources
    @Published var viewState: DeveloperViewState = .normal
    @Published var showingFileImporter: Bool = false
    @Published var showingPbxProjImporter: Bool = false
    @Published var warningGroups: [UnconnectedOutletsXIBWarningGroupModel] = []
    @Published var warnings: [XCodeWarningModel] = []
    @Published var message: ContentHeaderMessageModel?
    
    var isFormValid: Bool {
        switch toolType {
        case .missingResources:
            return !selectedProjectPath.isEmpty && !selectedPBXProjPath.isEmpty
        case .unconnectedOutletsXIB:
            return !selectedProjectPath.isEmpty
        case .unconnectedOutletsSwift:
            return !selectedProjectPath.isEmpty && !selectedPBXProjPath.isEmpty
        case .unusedFiles:
            return !selectedProjectPath.isEmpty && !selectedPBXProjPath.isEmpty
        }
    }
    
    private let resourceChecker = XCodeResourceHelper()
    
    func performCheck() {
        switch toolType {
        case .missingResources:
            checkMissingResources()
        case .unconnectedOutletsXIB:
            checkUnconnectedOutletsXIB()
        case .unconnectedOutletsSwift:
            print("Swift Method Not Implemented")
        case .unusedFiles:
            print("Swift Method Not Implemented")
        }
    }
    
    private func checkMissingResources() {
        viewState = .loading
        message = .getLoadingMessage(for: "Check Missing Resources")
        resourceChecker.checkProjectResources(projectPath: selectedProjectPath, pbxprojPath: formattedPBXProjPath) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let warnings):
                    self.warnings = warnings
                    self.viewState = .completed
                    self.message = ContentHeaderMessageModel(text: "Resource check completed successfully.", type: .success)
                case .failure(let error):
                    self.message = ContentHeaderMessageModel(text: "Error: \(error.localizedDescription)", type: .error)
                    self.viewState = .normal
                }
            }
        }
    }
    
    private func checkUnconnectedOutletsXIB() {
        viewState = .loading
        message = .getLoadingMessage(for: "Check Unconnected Outlets")
        resourceChecker.checkUnconnectedOutletsFromXIB(projectPath: selectedProjectPath) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let warnings):
                    self.warnings = warnings
                    self.groupingUnconnectedOutletsXIB()
                    self.viewState = .completed
                    self.message = ContentHeaderMessageModel(text: "Unconnected outlets check completed successfully.", type: .success)
                case .failure(let error):
                    self.viewState = .normal
                    self.message = ContentHeaderMessageModel(text: "Error: \(error.localizedDescription)", type: .error)
                }
            }
        }
    }
    
    private func groupingUnconnectedOutletsXIB() {
        let grouped = Dictionary(grouping: warnings) { $0.swiftName ?? "Unknown" }
        warningGroups = grouped.map { UnconnectedOutletsXIBWarningGroupModel(swiftName: $0.key, warnings: $0.value) }
    }
}
