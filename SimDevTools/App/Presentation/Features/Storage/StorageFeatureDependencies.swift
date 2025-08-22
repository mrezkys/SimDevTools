//
//  StorageFeatureDependencies.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation


protocol StorageFeatureStorage {
    func loadAppBundle() -> String?
}

struct UserDefaultsStorageFeatureStorage: StorageFeatureStorage {
    let db: UserDefaultsDatabaseProtocol
    
    init(db: UserDefaultsDatabaseProtocol) {
        self.db = db
    }
    
    func loadAppBundle() -> String? {
        return db.getValue(forKey: .selectedAppBundle)
    }
}
