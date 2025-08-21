//
//  UserDefaultsDatabaseProtocol.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

protocol UserDefaultsDatabaseProtocol {
    func save<T>(value: T, forKey key: UserDefaultsKey)
    func getValue<T>(forKey key: UserDefaultsKey) -> T?
    func removeValue(forKey key: UserDefaultsKey)
}
