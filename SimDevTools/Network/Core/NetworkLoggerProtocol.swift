//
//  NetworkLoggerProtocol.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

protocol NetworkLoggerProtocol {
    func log(request: URLRequest)
    func log(response: URLResponse?, data: Data?)
}
