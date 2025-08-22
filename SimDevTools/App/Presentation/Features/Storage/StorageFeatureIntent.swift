//
//  StorageFeatureIntent.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import Foundation

enum StorageFeatureIntent {
    case onAppear
    case loadAppBundle
    case appBundleLoaded(String?)

    case readSelectedAppUserDefault
    case didSuccessReadSelectedAppUserDefault([UDEntry])
    case didErrorReadSelectedAppUserDefault(StorageFeatureError)

    case searchTextChanged(String)
    case clearMessage
}
