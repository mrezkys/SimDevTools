//
//  SettingDependencies.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

// Setting Storage
protocol SettingStorage {
    func loadTargetSimulatorID() -> String?
    func saveTargetSimulatorID(_ id: String) throws
    
    func loadAppBundle() -> String?
    func saveAppBundle(_ bundle: String) throws
    func removeSavedAppBundle() throws
}

struct UserDefaultsSettingStorage: SettingStorage {
    let db: UserDefaultsDatabaseProtocol
    
    init(db: UserDefaultsDatabaseProtocol) {
        self.db = db
    }
    
    func loadTargetSimulatorID() -> String? {
        return db.getValue(forKey: .targetSimulatorID)
    }
    
    func saveTargetSimulatorID(_ id: String) throws {
        return db.save(value: id, forKey: .targetSimulatorID)
    }
    
    func loadAppBundle() -> String? {
        return db.getValue(forKey: .selectedAppBundle)
    }
    
    func saveAppBundle(_ bundle: String) throws {
        db.save(value: bundle, forKey: .selectedAppBundle)
    }
    
    func removeSavedAppBundle() throws {
        db.removeValue(forKey: .selectedAppBundle)
    }
}
