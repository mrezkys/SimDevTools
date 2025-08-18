//
//  NetworkServiceProtocol.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

protocol NetworkServiceProtocol {
    init(logger: NetworkLoggerProtocol)
    func fetchData(
        from urlString: String,
        method: NetworkRequestType,
        headers: [String: String]?,
        requestBody: Encodable?,
        completion: @escaping (Result<Data, Error>) -> Void
    )
}
