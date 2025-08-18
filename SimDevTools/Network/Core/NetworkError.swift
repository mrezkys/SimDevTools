//
//  NetworkError.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badResponse(statusCode: Int, data: Data?)
    case decodingError(Error, String)
    case unknown(Error)
    case noData
    case custom(String)
    
    var localizedDescription: String {
        switch self {
        case .badURL:
            return "The URL is invalid."
        case .badResponse(let statusCode, _):
            return "Received an invalid response with status code: \(statusCode)."
        case .decodingError(let error, let context):
            return "Failed to decode the response. Error: \(error.localizedDescription). Context: \(context)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .noData:
            return "No data received from the server."
        case .custom(let message):
            return message
        }
    }
}
