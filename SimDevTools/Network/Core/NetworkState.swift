//
//  NetworkState.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

enum NetworkState<T> {
    case loading
    case success(T)
    case failure(Error)
}
