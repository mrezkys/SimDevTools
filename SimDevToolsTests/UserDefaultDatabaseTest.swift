//
//  UserDefaultDatabaseTest.swift
//  SimDevToolsTests
//
//  Created by Muhammad Rezky on 19/08/25.
//

import Testing
import Foundation
@testable import SimDevTools

@Suite("UserDefaultsDatabase")
struct UserDefaultDatabaseTest {
    private func createTestSuite() -> UserDefaults {
        let suiteName: String = "UD-\(UUID().uuidString)"
        let userDefault: UserDefaults = UserDefaults(suiteName: suiteName)!
        
        userDefault.removePersistentDomain(forName: suiteName)
        return userDefault
    }
    
    @Test("Save and Get Value")
    func saveAndGet() {
        let db: UserDefaultsDatabaseProtocol = UserDefaultsDatabase(
            userDefaults: createTestSuite()
        )
        
        let testAppBundle: String = "com.test.app"
        db.save(value: testAppBundle, forKey: .selectedAppBundle)
        let value: String? = db.getValue(forKey: .selectedAppBundle)
        
        #expect(value == testAppBundle)
    }
    
    @Test("Remove")
    func remove() {
        let db: UserDefaultsDatabaseProtocol = UserDefaultsDatabase(
            userDefaults: createTestSuite()
        )
        
        let testAppBundle: String = "com.test.app"
        db.save(value: testAppBundle, forKey: .selectedAppBundle)
        db.removeValue(forKey: .selectedAppBundle)
        let value: String? = db.getValue(forKey: .selectedAppBundle)
        
        #expect(value == nil)
    }
}
