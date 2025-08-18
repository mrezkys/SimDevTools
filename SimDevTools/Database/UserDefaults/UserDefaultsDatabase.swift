//
//  UserDefaultsDatabase.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

class UserDefaultsDatabase: UserDefaultsDatabaseProtocol {
    private let defaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }

    func save<T>(value: T, forKey key: UserDefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    func getValue<T>(forKey key: UserDefaultsKey) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }

    func removeValue(forKey key: UserDefaultsKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
