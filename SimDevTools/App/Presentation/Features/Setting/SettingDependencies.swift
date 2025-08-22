//
//  SettingDependencies.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

// Setting Storage
protocol SettingStorage {
    func loadAppBundle() -> String?
    func saveAppBundle(_ bundle: String) throws
}

struct UserDefaultsSettingStorage: SettingStorage {
    let db: UserDefaultsDatabaseProtocol
    
    init(db: UserDefaultsDatabaseProtocol) {
        self.db = db
    }
    
    func loadAppBundle() -> String? {
        return db.getValue(forKey: .selectedAppBundle)
    }
    
    func saveAppBundle(_ bundle: String) throws {
        db.save(value: bundle, forKey: .selectedAppBundle)
    }
}
